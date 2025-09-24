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

  # Don't set src here - we'll create our own source structure
  src = null;

  buildInputs = with pkgs; [
    # Dependencies mentioned in bgfx readme
    libGL
    xorg.libX11
    xorg.xorgproto
    # Build tools
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
    # Patch the genie binary to work in Nix environment
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" bx/tools/bin/linux/genie
    patchelf --set-rpath "${
      pkgs.lib.makeLibraryPath (
        with pkgs;
        [
          stdenv.cc.cc.lib
          glibc
        ]
      )
    }" bx/tools/bin/linux/genie

    # Change to bgfx directory for build
    cd bgfx
  '';

  buildPhase = ''
    # Verify we can find the genie tool
    ls -la ../bx/tools/bin/linux/

    # Test running genie directly
    echo "Testing genie execution:"
    ../bx/tools/bin/linux/genie --help || echo "Genie failed to run"

    # Build bgfx with clang
    make linux-clang-release64
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib,include}

    # Copy binaries and libraries from linux64_clang build directory
    if [ -d ".build/linux64_clang/bin" ]; then
      # Separate executables and libraries
      for file in .build/linux64_clang/bin/*; do
        if [[ -f "$file" ]]; then
          filename=$(basename "$file")
          if [[ "$filename" == lib*.a ]] || [[ "$filename" == lib*.so* ]]; then
            # It's a library, copy to lib directory
            cp "$file" $out/lib/
          else
            # It's an executable, copy to bin directory
            cp "$file" $out/bin/
          fi
        fi
      done
    fi

    # Copy any additional libraries from lib directory if it exists
    if [ -d ".build/linux64_clang/lib" ]; then
      cp -r .build/linux64_clang/lib/* $out/lib/
    fi

    # Copy headers
    cp -r include/* $out/include/

    # Also copy bimg and bx headers since they're dependencies
    cp -r ../bimg/include/* $out/include/
    cp -r ../bx/include/* $out/include/

  '';

  meta = with pkgs.lib; {
    description = "Cross-platform rendering library";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
