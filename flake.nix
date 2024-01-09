{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nci.url = "github:yusdacra/nix-cargo-integration";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {
    flake-parts,
    nci,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.nci.flakeModule
        inputs.treefmt-nix.flakeModule
        ./crates.nix
      ];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        pkgs,
        ...
      }: let
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        crateName = cargoToml.package.name;
        crateOutputs = config.nci.outputs.${crateName};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "NARFMAP";
          version = cargoToml.package.version;

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

        packages.narf = crateOutputs.packages.release;

        devShells.narf = crateOutputs.devShell;

        # FIXME
        # devShells.default = {
        #   name = "NARFMAP";

        #   imports = [
        #   ];

        #   packages = [
        #     pkgs.boost
        #     pkgs.gnumake
        #     pkgs.gtest
        #     pkgs.zlib
        #   ];
        #   env = {
        #     BOOST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.boost}/include";
        #     BOOST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.boost}/lib";
        #     GTEST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.gtest}/include";
        #     GTEST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.gtest}/lib";
        #     GTEST_ROOT = "${pkgs.gtest}";
        #     LD_LIBRARY_PATH = "${pkgs.lib.getLib pkgs.gtest}/lib";
        #   };
        # };

        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.alejandra.enable = true;
          programs.clang-format.enable = true;
          programs.deadnix.enable = true;
          programs.prettier.enable = true;
          programs.prettier.settings = {
            editorconfig = true;
            embeddedLanguageFormatting = "auto";
          };
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
