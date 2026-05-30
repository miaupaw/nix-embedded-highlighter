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
          ];

          shellHook = '' # bash
            echo "VS Code Extension Dev Environment"
            echo "Run 'vsce package' to build the extension."
            echo "Run 'npm exec ovsx publish' to release to Open VSX."
          '';
        };

        packages.hello-js = pkgs.writeText "hello.js" '' // javascript
          const greet = (name) => {
            const msg = `Hello, ''${name}!`;
            console.log(msg);
            return msg;
          };

          greet("Nix");
        '';

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nix-embedded-highlighter";
          version = "0.1.3";
          src = ./.;

          nativeBuildInputs = [ pkgs.nodejs_22 pkgs.vsce ];

          buildPhase = '' # bash
            # vsce needs a package.json to work
            # We skip 'npm install' because we have no dependencies yet
            vsce package --out nix-embedded-highlighter-0.1.3.vsix
          '';
          installPhase = '' # bash
            mkdir -p $out/share/vscode/extensions
            cp *.vsix $out/share/vscode/extensions/
          '';
        };
      }
    );
}
