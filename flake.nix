# {
#   description = "LaTeX Document Demo";
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
#     flake-utils.url = "github:numtide/flake-utils";
#   };
#   outputs = { self, nixpkgs, flake-utils }:
#     with flake-utils.lib;
#     eachSystem allSystems (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#         tex = pkgs.texlive.combine {
#           inherit (pkgs.texlive) scheme-minimal latex-bin latexmk;
#         };
#       in rec {
#         packages = {
#           document = pkgs.stdenvNoCC.mkDerivation rec {
#             name = "latex-demo-document";
#             src = self;
#             buildInputs = [ pkgs.coreutils tex ];
#             phases = [ "unpackPhase" "buildPhase" "installPhase" ];
#             buildPhase = ''
#               export PATH="${pkgs.lib.makeBinPath buildInputs}";
#               mkdir -p .cache/texmf-var
#               SOURCE_DATE_EPOCH=$(date -d "2025-04-30" +%s) \
#               # make env
#               env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
#                 SOURCE_DATE_EPOCH=$(date -d "2025-04-30" +%s) \
#                 latexmk -interaction=nonstopmode -pdf -lualatex \
#                 -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
#                 -usepretex document.tex
#             '';
#             installPhase = ''
#               rm -f $out
#               mkdir -p $out
#               cp document.pdf $out/
#             '';
#           };
#         };
#         defaultPackage = packages.document;
#       });
# }
{
  description = "LaTeX Document with Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-demo-document";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                SOURCE_DATE_EPOCH=$(date -d "2025-04-30" +%s) \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
                -usepretex document.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp document.pdf $out/
            '';
          };
          default = self.packages.${system}.document;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # LaTeX
            tex

            # LaTeX LSP and formatter
            texlab
            tex-fmt

            # PDF reader
            okular

          ];
        };
      });
}
