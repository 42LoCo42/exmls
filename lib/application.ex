defmodule ExMLS do
  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Hello, #{hello()}!")
    {:ok, self()}
  end

  @doc """
  Hello world.

  ## Examples

      iex> ExMLS.hello()
      :world

  """
  def hello do
    :world
  end
end
