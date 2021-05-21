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
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  # strip meta from Name in Jason.encode
  Protocol.derive(Jason.Encoder, Name, except: [:__meta__])

  # send json response
  defp respond(conn, code, payload) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, payload)
  end

  # send names record if success
  defp send_result(conn, names) when is_list(names) do
    payload = Jason.encode!(%{"code" => 200, "data" => names})

    conn |> respond(200, payload)
  end

  # send error message
  defp send_result(conn, message) when is_bitstring(message) do
    payload = Jason.encode!(%{"code" => 404, "message" => message})

    conn |> respond(400, payload)
  end

  # error message: invalid id (id must be a string of integer or integers separated by commas)
  defp invalid_id(conn, string_ids) do
    conn |> send_result("invalid or empty ID: \"#{string_ids}\"")
  end

  # error message: Name.id not exist
  defp not_exist_id(conn, string_ids) do
    conn |> send_result("resource with ID #{string_ids} not exist")
  end

  defp query_enum_ids(conn, enum_ids) when enum_ids == [] do
    conn |> invalid_id(Enum.join(enum_ids, ","))
  end

  defp query_enum_ids(conn, enum_ids) do
    names =
      Repo.all(
        from(n in Name,
          join: i in fragment("unnest(?::int[])", ^enum_ids),
          on: n.id == i,
          select: n
        )
      )

    result(conn, enum_ids, names)
  end

  defp enum_list_ids(conn, list_ids) when list_ids == [] do
    conn |> invalid_id(Enum.join(list_ids, ","))
  end

  defp enum_list_ids(conn, list_ids) do
    enum_ids =
      Enum.flat_map(list_ids, fn string_id ->
        case Integer.parse(string_id) do
          # transform to integer
          {int_id, _} -> [int_id]
          # skip the value
          :error -> []
        end
      end)

    query_enum_ids(conn, enum_ids)
  end

  defp result(conn, enum_ids, names) when names == [] do
    conn |> not_exist_id(Enum.join(enum_ids, ","))
  end

  defp result(conn, _, names) do
    conn |> send_result(names)
  end

  defp match_regex(conn, string_ids) do
    if Regex.match?(~r{^\d+(,\d+)*$}, string_ids),
      do: conn |> enum_list_ids(String.split(string_ids, ",", trim: true)),
      else: conn |> invalid_id(string_ids)
  end

  get "/" do
    map_params = Plug.Conn.fetch_query_params(conn).query_params

    # send all names when no id in_query params
    if Map.has_key?(map_params, "id"),
      do: conn |> match_regex(Map.fetch!(map_params, "id")),
      else: conn |> send_result(Repo.all(Name))
  end

  match _ do
    conn |> send_result("Error 404 Not Found")
  end
end
