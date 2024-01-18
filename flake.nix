{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
      pkgs = nixpkgs.legacyPackages.${system};
      inherit
        (poetry2nix.lib.mkPoetry2Nix {inherit pkgs;})
        mkPoetryApplication
        overrides
        defaultPoetryOverrides
        ;
    in {
      packages = {
        myapp = mkPoetryApplication {
          projectDir = self;
          preferWheels = true;
          overrides = [
            defaultPoetryOverrides # have to inverse the order from withDefaults
            (
              self: super: {
                mkdocs-material = super.mkdocs-material.overridePythonAttrs (old: {
                  postPatch = "";
                });

                # rpds-py = super.rpds-py.overridePythonAttrs (old: {
                #   cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
                #     inherit (old) src;
                #     name = "${old.pname}-${old.version}";
                #     sha256 = "sha256-aPmi/5UAkePf4nC2zRjXY+vZsAsiRZqTHyZZmzFHcqE=";
                #   };
                # });
              }
            )
          ];
        };
        default = self.packages.${system}.myapp;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.myapp];
        packages = [pkgs.poetry];
      };
    });
}
