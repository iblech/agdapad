{ lib, stdenv }:  

stdenv.mkDerivation rec {
  name = "agdapad-static"; 
  src = ../frontend;

  installPhase = ''
    mkdir $out
    cp -r * $out/
  '';
}
