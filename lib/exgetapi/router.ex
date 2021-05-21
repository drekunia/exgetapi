defmodule Exgetapi.Router do
  use Plug.Router
  use Plug.Debugger
  import Exgetapi
  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get("/", do: validate_id(conn))
  match(_, do: error_path(conn))
end
