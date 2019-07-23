defmodule TestProject.Endpoint do
  use Plug.Router
  require Logger

  plug(Plug.Logger)
  # NOTE: The line below is only necessary if you care about parsing JSON
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  def init(options) do
    options
  end

  def start_link do
    # NOTE: This starts Cowboy listening on the default port of 4000
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [])
  end

  get "/" do
    send_resp(conn, 200, "Hello, world!")
  end
end
