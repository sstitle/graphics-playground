{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "bx";
  commit = "81ea23aba00953a19bb679eb34faa31983f67b52";
  version = commit;

  src = pkgs.fetchFromGitHub {
    owner = "bkaradzic";
    repo = "bx";
    rev = commit;
    sha256 = "sha256-4gBhnCzRr7xeF7pPRBYkHjdLCxhDdSAzwKGX5QQFsfc=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';

  meta = with pkgs.lib; {
    description = "Base X-platform library for bgfx";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
