{
  description = "A Nix-flake-based Zig development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [zig];
      };
    });

    packages = forEachSupportedSystem ({pkgs}: {
      dragen = pkgs.stdenv.mkDerivation {
        pname = "NARFMAP";
        version = "1.4.0";

        src = ./.;

        buildInputs = [
          pkgs.boost
          pkgs.gnumake
          pkgs.gtest
          pkgs.zlib
        ];

        buildPhase = ''
          make
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp build/release/compare $out/bin
          cp build/release/dragen-os $out/bin
        '';

        env = {
          BOOST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.boost}/include";
          BOOST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.boost}/lib";
          GTEST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.gtest}/include";
          GTEST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.gtest}/lib";
          GTEST_ROOT = "${pkgs.gtest}";
          LD_LIBRARY_PATH = "${pkgs.lib.getLib pkgs.gtest}/lib";
          LIBCLANG_PATH = "${pkgs.lib.getLib pkgs.llvmPackages.libclang.lib}/lib";
        };

        meta = with pkgs.lib; {
          homepage = "https://github.com/nixvital/nix-based-cpp-starterkit";
          description = ''
            A template for Nix based C++ project setup.";
          '';
          licencse = licenses.mit;
          platforms = with platforms; linux ++ darwin;
          maintainers = [maintainers.breakds];
        };
      };
    });
  };
}
