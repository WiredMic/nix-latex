{
  description = "Flake to compile latex documents";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-minimal latex-bin latexmk;
        };

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # LaTeX
            tex

            # LaTeX LSP and formatter
            texlab
            # digestif
            tex-fmt

            # PDF reader
            okular

            figlet
          ];

          # to get the time correct
          SOURCE_DATE_EPOCH = self.sourceInfo.lastModified;
          shellHook = "";
        };

      });
}

# https://docs.platformio.org/en/latest/integration/ide/emacs.html
