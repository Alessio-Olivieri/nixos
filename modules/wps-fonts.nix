{ pkgs, ... }:

let
  # Define the font package locally
  wps-fonts = pkgs.stdenv.mkDerivation {
    pname = "wps-fonts";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "iamdh4";
      repo = "ttf-wps-fonts";
      rev = "master";
      # If this hash fails, Nix will tell you the correct one. Replace it then.
      sha256 = "sha256-x+grMnpEGLkrGVud0XXE8Wh6KT5DoqE6OHR+TS6TagI=";
    };

    installPhase = ''
      mkdir -p $out/share/fonts/wps-fonts
      find . -iname "*.ttf" -exec cp {} $out/share/fonts/wps-fonts \;
      find . -iname "*.tbf" -exec cp {} $out/share/fonts/wps-fonts \;
    '';
  };
in
{
  # Add the fonts to the system
  fonts.packages = [ wps-fonts ];
}