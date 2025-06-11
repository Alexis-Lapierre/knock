{
  inputs = {
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    libgourou-utils.url = "github:esn/libgourou-utils";
    libgourou-utils.inputs.nixpkgs.follows = "nixpkgs";

    inept-epub.url = "github:esn/inept-epub";
    inept-epub.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@flakes: let
    nixpkgs = flakes.nixpkgs.legacyPackages.x86_64-linux;
    libgourou-utils = flakes.libgourou-utils.defaultPackage.x86_64-linux;
    inept-epub = flakes.inept-epub.defaultPackage.x86_64-linux;
  in {
    defaultPackage.x86_64-linux = nixpkgs.stdenv.mkDerivation {
        pname = "knock";
        version = "0.1.0-alpha";
        src = self;
        nativeBuildInputs = [ nixpkgs.makeWrapper ];
        buildInputs = [
          (nixpkgs.python3.withPackages(python3Packages: [ python3Packages.python_magic ]))
          libgourou-utils inept-epub
        ];
        installPhase = ''
          mkdir -p $out/bin
          chmod +x knock
          cp knock $out/bin
          wrapProgram $out/bin/knock --prefix PATH : ${nixpkgs.lib.makeBinPath [libgourou-utils inept-epub]}
        '';

        meta = {
          description = "A CLI tool to convert ACSM files to DRM-free EPUB files";
          homepage = "https://github.com/BentonEdmondson/knock";
          license = [ nixpkgs.lib.licenses.gpl3Only ];
          maintainers = [{
            name = "Benton Edmondson";
            email = "bentonedmondson@gmail.com";
          }];
          # potentially others, but I'm only listed those tested
          platforms = [ "x86_64-linux" ];
        };
      };

  };
}
