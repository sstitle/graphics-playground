{
  pkgs ? import <nixpkgs> { },
  bgfx-source,
  bimg-source,
  bx-source,
  ...
}:

pkgs.stdenv.mkDerivation {
  pname = "bgfx";
  version = bgfx-source.version;

  # We define our own source structure
  src = null;

  buildInputs = with pkgs; [
    cmake
    ninja
    python3
    clang
  ];

  nativeBuildInputs = with pkgs; [
    patchelf
  ];

  unpackPhase = ''
    # Create a workspace directory structure with all three projects as siblings
    mkdir -p workspace
    cd workspace

    # Copy all three source trees as siblings
    cp -r ${bgfx-source} bgfx
    cp -r ${bimg-source} bimg  
    cp -r ${bx-source} bx

    # Make directories writable for the build process
    chmod -R u+w bgfx bimg bx
  '';

  configurePhase = ''
    # Change to bgfx directory for build
    cd bgfx
  '';

  # Platform-specific build and install logic
  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';

  meta = with pkgs.lib; {
    description = "Cross-platform rendering library";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
