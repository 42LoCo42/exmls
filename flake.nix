{
  description = "Elixir implementation of the MLS protocol";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pname = "exmls";
        version = "0.1.0";
        elixir = pkgs.elixir_1_15;
        src = ./.;

        mixFodDeps = pkgs.beamPackages.fetchMixDeps {
          pname = "mix-deps-${pname}";
          inherit version elixir src;

          hash = "sha256-ahA9kIJXsFxXzEJmrgmuPPd+Kjlx+5wwUvU6e0L3DU0=";
        };
      in
      rec {
        defaultPackage = pkgs.beamPackages.mixRelease {
          inherit pname version elixir src mixFodDeps;

          nativeBuildInputs = with pkgs; [
            zstd # for bakeware binary compression
          ];

          installPhase = ''
            mix release
            mkdir -p $out/bin
            cp _build/prod/rel/bakeware/* $out/bin
          '';
          dontStrip = true; # kills bakeware header otherwise
        };

        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          packages = with pkgs; [
            bashInteractive
            elixir-ls
            just
          ];
        };
      });
}
