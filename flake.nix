{
  description = "Elixir implementation of the MLS protocol";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pname = "exmls";
        version = "0.1.0";
        src = ./.;

        mixFodDeps = pkgs.beamPackages.fetchMixDeps {
          pname = "mix-deps-${pname}";
          inherit version src;

          hash = "sha256-J1gAURci95hQWVb3bHnqL7WFfKB1siQPJ9BxyOxl4OQ=";
        };
      in
      {
        defaultPackage = pkgs.beamPackages.mixRelease {
          inherit pname version src mixFodDeps;

          nativeBuildInputs = with pkgs; [
            elixir_1_15
          ];
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            bashInteractive
            beamPackages.hex
            elixir-ls
            elixir_1_15
          ];
        };
      });
}
