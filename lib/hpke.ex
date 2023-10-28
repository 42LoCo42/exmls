defmodule ExMLS.HPKE do
  @on_load :load_nifs

  def load_nifs() do
    System.get_env("NIF") |> String.to_charlist() |> :erlang.load_nif(nil)
  end

  def compare(_a, _b), do: :erlang.nif_error("Load NIF!")
end
