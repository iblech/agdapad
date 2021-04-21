{ lib, stdenv, agda }:

let
  agdaWithPackages = agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories ]);
in

stdenv.mkDerivation rec {
  name = "agda-slim"; 
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    ls -laR $out
    agdabin=$(< ${agdaWithPackages}/bin/agda cut -d'"' -f2 | grep agda)
    cp $agdabin $out/bin/.agda-bin
    cp ${agdaWithPackages}/bin/agda $out/bin
    sed -i -e "s+$agdabin+$out/bin/.agda-bin+" -e "s+--with-compiler=[^ ]*++" $out/bin/agda
    cp $agdabin-mode $out/bin/agda-mode
  '';
}
