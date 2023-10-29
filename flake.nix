{
  description = "Elixir implementation of the MLS protocol";

  inputs.obscura.url = "github:42loco42/obscura";
  inputs.obscura.inputs.nixpkgs.follows = "nixpkgs";
  inputs.obscura.inputs.flake-utils.follows = "flake-utils";

  outputs = { nixpkgs, flake-utils, obscura, ... }:
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

          hash = "sha256-wU56kAREfovnqFCz7tU+3T0Q8TEyf7gzKUD8FsEzCls=";
        };

        defaultPackage = pkgs.beamPackages.mixRelease {
          inherit pname version elixir src mixFodDeps;

          nativeBuildInputs = with pkgs; [
            zstd # for bakeware binary compression
          ];

          preBuild = ''export NIF_LOC="$out/lib/nif"'';

          installPhase = ''
            mix release
            mkdir -p $out/bin $out/lib
            cp _build/prod/rel/bakeware/exmls $out/bin
            cp nif/nif.so $out/lib
          '';
          dontStrip = true; # kills bakeware header otherwise

          ERL_INCLUDE_PATH = "${pkgs.erlang}/lib/erlang/usr/include";
          HPKE = "${obscura.packages.${system}.libhpke}";
        };

        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          packages = with pkgs; [
            bashInteractive
            bear
            elixir-ls
            just
          ];

          inherit (defaultPackage) ERL_INCLUDE_PATH HPKE;
          NIF_LOC = "./nif/nif";
        };
      in
      { inherit defaultPackage devShell; });
}
