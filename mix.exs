defmodule ExMLS.MixProject do
  use Mix.Project

  def project do
    [
      app: :exmls,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:bandit, "~> 0.7.7"},
      {:websock_adapter, "~> 0.5.4"}
    ]
  end
end
