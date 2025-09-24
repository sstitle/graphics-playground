{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "bimg";
  commit = "a1a2ae3c129d8c33e765eecd91801bffd985c317";
  version = commit;

  src = pkgs.fetchFromGitHub {
    owner = "bkaradzic";
    repo = "bimg";
    rev = commit;
    sha256 = "sha256-V8NTmXxwNnfiwWAnarMHppIp6ZV3UbGAleZyvvKDNTs=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';

  meta = with pkgs.lib; {
    description = "Image library for bgfx";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
