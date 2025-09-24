{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "bgfx";
  commit = "5eeed00aaa28c3c8d509eb77c5f0c646d68c40d4";
  version = commit;

  src = pkgs.fetchFromGitHub {
    owner = "bkaradzic";
    repo = "bgfx";
    rev = commit;
    sha256 = "sha256-3x+wUa1P4aw65CasSSoTSpaFURpSzdxImCZat0Bw49A=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';

  meta = with pkgs.lib; {
    description = "bfgx - cross-platform 'bring your own engine' style rendering library";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
