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

        nif = pkgs.stdenv.mkDerivation {
          name = "nif";
          src = ./nif;
          ERL_INCLUDE_PATH = "${pkgs.erlang}/lib/erlang/usr/include";
          HPKE = "${obscura.packages.${system}.libhpke}";
        };

        defaultPackage = pkgs.beamPackages.mixRelease {
          inherit pname version elixir src mixFodDeps;

          nativeBuildInputs = with pkgs; [
            zstd # for bakeware binary compression
          ];

          installPhase = ''
            mix release
            mkdir -p $out/bin
            cp _build/prod/rel/bakeware/exmls $out/bin
            wrapProgram $out/bin/exmls --set NIF "${nif}/nif"
          '';
          dontStrip = true; # kills bakeware header otherwise

          inherit (nif) ERL_INCLUDE_PATH HPKE;
        };

        devShell = pkgs.mkShell {
          inputsFrom = [ defaultPackage ];
          packages = with pkgs; [
            bashInteractive
            bear
            elixir-ls
            just
          ];

          inherit (nif) ERL_INCLUDE_PATH HPKE;
          NIF = "./nif/nif";
        };
      in
      { inherit defaultPackage devShell; });
}
