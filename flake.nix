{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv";
    nci.url = "github:yusdacra/nix-cargo-integration";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {
    flake-parts,
    nci,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
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
        crateOutputs = config.nci.outputs."my-crate";
      in {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "NARFMAP";
          version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.version;

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

        packages.narf = pkgs.rustPlatform.buildRustPackage rec {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;

          src = ./.;

          #cargoSha256 = lib.fakeSha256;
          cargoSha256 = "sha256-RTcE5CoLGUXXYeBId/ihGMTkfEYtw7Wr9I3UlvkeQYE=";

          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
          doCheck = false;

          preBuild = with pkgs; ''
            # From: https://github.com/NixOS/nixpkgs/blob/1fab95f5190d087e66a3502481e34e15d62090aa/pkgs/applications/networking/browsers/firefox/common.nix#L247-L253
            # Set C flags for Rust's bindgen program. Unlike ordinary C
            # compilation, bindgen does not invoke $CC directly. Instead it
            # uses LLVM's libclang. To make sure all necessary flags are
            # included we need to look in a few places.
            export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
              $(< ${stdenv.cc}/nix-support/libc-cflags) \
              $(< ${stdenv.cc}/nix-support/cc-cflags) \
              $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
              ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
              ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"} \
            "
          '';

          meta = with pkgs.lib; {
            # TODO description = cargoToml.package.description;
            # TODO homepage = cargoToml.package.homepage;
            license = with licenses; [mit];
            maintainers = with maintainers; [edmundmiller];
          };
        };

        devShells.narf = crateOutputs.devShell;

        devenv.shells.default = {
          name = "NARFMAP";

          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          # https://devenv.sh/reference/options/
          packages = [
            pkgs.boost
            pkgs.gnumake
            pkgs.gtest
            pkgs.zlib
          ];
          languages.cplusplus.enable = true;
          env = {
            BOOST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.boost}/include";
            BOOST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.boost}/lib";
            GTEST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.gtest}/include";
            GTEST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.gtest}/lib";
            GTEST_ROOT = "${pkgs.gtest}";
            LD_LIBRARY_PATH = "${pkgs.lib.getLib pkgs.gtest}/lib";
          };
        };

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
