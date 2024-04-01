{ lib, stdenvNoCC, agda }:

let
  agdaWithPackages = agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories p._1lab ]);
in

stdenvNoCC.mkDerivation rec {
  name = "agda-slim"; 
  dontUnpack = true;

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
