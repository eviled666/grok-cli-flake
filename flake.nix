{
  description = "Nix flake for running and developing grok-cli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-darwin"
    ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nodejs = pkgs.nodejs_20;

        grok-cli = pkgs.buildNpmPackage {
          pname = "grok-cli";
          version = "0.0.34";
          src = ./.;

          npmDeps = pkgs.importNpmLock { npmRoot = ./.; };
          npmConfigHook = pkgs.importNpmLock.npmConfigHook;

          nativeBuildInputs = [ nodejs ];
          npmBuildScript = "build";

          meta = {
            description = "An open-source AI agent that brings Grok to your terminal";
            mainProgram = "grok";
            license = pkgs.lib.licenses.mit;
            platforms = [ "x86_64-linux" "aarch64-darwin" ];
          };
        };
      in
      {
        packages.default = grok-cli;
        packages.grok = grok-cli;

        apps.default = {
          type = "app";
          program = "${grok-cli}/bin/grok";
        };

        apps.grok = {
          type = "app";
          program = "${grok-cli}/bin/grok";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            nodejs
            pkgs.nodePackages.npm
            pkgs.bun
            pkgs.git
            pkgs.ripgrep
          ];
        };
      }
    );
}
