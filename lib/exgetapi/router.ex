defmodule Exgetapi.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  require Enum

  alias Exgetapi.Repo
  alias Exgetapi.Name
  require Protocol
  import Ecto.Query

  plug(Plug.Logger, log: :debug)
  plug(Plug.Head)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  Protocol.derive(Jason.Encoder, Name, except: [:__meta__])

  def init(options) do
    IO.inspect(options)
  end

  defp respond(conn, code, payload) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, payload)
  end

  defp send(conn, code, names) when is_list(names) do
    payload = Jason.encode!(%{"code" => code, "data" => names})

    conn |> respond(code, payload)
  end

  defp send(conn, code, message) when is_bitstring(message) do
    payload = Jason.encode!(%{"code" => code, "message" => message})

    conn |> respond(code, payload)
  end

  defp invalid_id(conn, string_ids) do
    conn |> send(404, "invalid or empty ID: \"#{string_ids}\"")
  end

  defp not_exist_id(conn, string_ids) do
    conn |> send(404, "resource with ID #{string_ids} not exist")
  end

  get "/" do
    map_params = Plug.Conn.fetch_query_params(conn).query_params

    # check if there's id on query params
    if Map.has_key?(map_params, "id") do
      string_ids = Map.fetch!(map_params, "id")
      list_ids = String.split(string_ids, ",", trim: true)

      if list_ids != [] do
        enum_ids =
          Enum.flat_map(list_ids, fn string_id ->
            if Regex.match?(~r{\A\d*\z}, string_id) do
              {int_id, _} = Integer.parse(string_id)
              [int_id]
            else
              []
            end
          end)

        if enum_ids != [] do
          query =
            from(n in Name,
              join: i in fragment("unnest(?::int[])", ^enum_ids),
              on: n.id == i,
              select: n
            )

          if Repo.all(query) != [] do
            conn |> send(200, Repo.all(query))
          else
            conn |> not_exist_id(string_ids)
          end
        else
          conn |> invalid_id(string_ids)
        end
      else
        conn |> invalid_id(string_ids)
      end
    else
      conn |> send(200, Repo.all(Name))
    end
  end

  match _ do
    conn |> send(404, "Error 404 Not Found")
  end
end
