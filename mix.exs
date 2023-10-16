defmodule ExMLS.MixProject do
  use Mix.Project

  @app :exmls

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        exmls: [
          steps: [:assemble, &Bakeware.assemble/1]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExMLS, []}
    ]
  end

  defp deps do
    [
      {:bakeware, "~> 0.2.4"},
      {:bandit, "~> 0.7.7"},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:enum_type, "~> 1.1"},
      {:typed_struct, "~> 0.3.0"},
      {:websock_adapter, "~> 0.5.4"}
    ]
  end
end
