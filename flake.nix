{
  description = "A VS Code extension for embedded Nix syntax highlighting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22
            vsce
            ovsx
          ];

          shellHook = '' # bash
            echo "VS Code Extension Dev Environment"
            echo "Run 'vsce package' to build the extension."
            echo "Run 'ovsx publish' to release to Open VSX."
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nix-embedded-highlighter";
          version = "0.0.1";
          src = ./.;
          
          nativeBuildInputs = [ pkgs.nodejs_22 pkgs.vsce ];

          buildPhase = '' # bash
            # vsce needs a package.json to work
            # We skip 'npm install' because we have no dependencies yet
            vsce package --out nix-embedded-highlighter-0.0.1.vsix
          '';
          installPhase = '' # bash
            mkdir -p $out/share/vscode/extensions
            cp *.vsix $out/share/vscode/extensions/
          '';
        };
      }
    );
}
