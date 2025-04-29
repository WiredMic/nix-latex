# {
#   # https://flyx.org/nix-flakes-latex/
#   description = "LaTeX Document with Development Environment";

#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
#     flake-utils.url = "github:numtide/flake-utils";
#   };

#   outputs = { self, nixpkgs, flake-utils, ... }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#         tex = pkgs.texlive.combine {
#           inherit (pkgs.texlive)
#             scheme-basic latex-bin latexmk fontspec
#             # Math
#             lualatex-math unicode-math
#             # Bib
#             biblatex biber
#             # Multifile
#             subfiles;
#         };
#       in {
#         packages = {
#           document = pkgs.stdenvNoCC.mkDerivation rec {
#             name = "latex-demo-document";
#             src = self;
#             buildInputs = [
#               pkgs.coreutils
#               tex
#               pkgs.libertinus

#             ];
#             phases = [ "unpackPhase" "buildPhase" "installPhase" ];
#             buildPhase = ''
#               export PATH="${pkgs.lib.makeBinPath buildInputs}";
#               mkdir -p .cache/texmf-var
#               env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
#                 SOURCE_DATE_EPOCH=$(date -d "2025-04-30" +%s) \
#                 OSFONTDIR=${pkgs.libertinus}/share/fonts \
#                 latexmk -interaction=nonstopmode -pdf -lualatex -bibtex \
#                 -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
#                 -usepretex document.tex
#             '';
#             installPhase = ''
#               mkdir -p $out
#               cp document.pdf $out/
#             '';
#           };
#           default = self.packages.${system}.document;
#         };

#         devShells.default = pkgs.mkShell {
#           packages = with pkgs; [
#             # LaTeX
#             tex

#             # LaTeX LSP and formatter
#             texlab
#             tex-fmt

#             # PDF reader
#             okular

#           ];
#         };
#       });
# }

{
  # https://flyx.org/nix-flakes-latex/
  description = "LaTeX Document with Subfiles and Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-basic latex-bin latexmk fontspec
            # Math
            lualatex-math unicode-math
            # Bib
            biblatex biber
            # Multifile
            subfiles;
        };

        # Function to create a LaTeX document build
        makePdf = { name, mainFile ? "${name}.tex", outputName ? name
          , workingDir ? "." }:
          let buildInputs = [ pkgs.coreutils tex pkgs.libertinus ];
          in pkgs.stdenvNoCC.mkDerivation {
            name = "${name}-pdf";
            src = self;
            inherit buildInputs;
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              cd ${workingDir}
              env TEXMFHOME=../.cache TEXMFVAR=../.cache/texmf-var \
                SOURCE_DATE_EPOCH=$(date -d "2025-04-30" +%s) \
                OSFONTDIR=${pkgs.libertinus}/share/fonts \
                latexmk -interaction=nonstopmode -pdf -lualatex -bibtex \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
                -usepretex ${mainFile}
            '';
            installPhase = ''
              mkdir -p $out
              cp ${outputName}.pdf $out/
            '';
          };

      in {
        packages = {
          # Main document
          document = makePdf { name = "document"; };

          # Individual chapters in subfolders
          bivector = makePdf {
            name = "bivector";
            mainFile = "bivector.tex";
            outputName = "bivector";
            workingDir = "chapters/bivector";
          };

          # Add more chapters as needed
          # chapter2 = makePdf {
          #   name = "chapter2";
          #   mainFile = "chapter2.tex";
          #   outputName = "chapter2";
          #   workingDir = "chapters/chapter2";
          # };

          # Set the default package
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
