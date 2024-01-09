{...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
    crateName = cargoToml.package.name;
  in {
    # declare projects
    nci.projects.${crateName}.path = ./.;
    # configure crates
    nci.crates.${crateName} = {
      drvConfig.mkDerivation = {
        buildInputs = [
          pkgs.boost
          pkgs.gnumake
          pkgs.gtest
          pkgs.zlib
        ];
      };
    };
  };
}
