defmodule Web.Hello do
  defmodule FooException do
    defexception message: "Oh no something bad happened!", plug_status: 400
  end

  use Plug.Router
  use Plug.ErrorHandler
  # use Plug.Debugger

  plug(Plug.Logger)

  plug(Plug.Static, at: "/", only: ["favicon.ico"], from: :exmls)
  plug(Plug.Static, at: "/static", from: :exmls)

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, """
    Use the JavaScript console to interact using websockets

    sock = new WebSocket("ws://localhost:37812/ws")
    sock.addEventListener("message", console.log)
    sock.addEventListener("open", () => sock.send("ping"))
    """)
  end

  get "/foo" do
    _ = conn
    raise(FooException)
  end

  get "/ws" do
    conn
    |> WebSockAdapter.upgrade(Web.EchoServer, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    send_resp(conn, conn.status, reason.message)
  end
end

defmodule Web.EchoServer do
  def init(opts), do: {:ok, opts}

  def handle_in({"ping", [opcode: :text]}, state) do
    {:reply, :ok, {:text, "pong"}, state}
  end

  def terminate(_reason, state), do: {:ok, state}
end
