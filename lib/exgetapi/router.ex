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

  # strip meta from Name in Jason.encode
  Protocol.derive(Jason.Encoder, Name, except: [:__meta__])

  # send json response
  defp respond(conn, code, payload) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, payload)
  end

  # send names record if success
  defp send(conn, code, names) when is_list(names) do
    payload = Jason.encode!(%{"code" => code, "data" => names})

    conn |> respond(code, payload)
  end

  # send error message
  defp send(conn, code, message) when is_bitstring(message) do
    payload = Jason.encode!(%{"code" => code, "message" => message})

    conn |> respond(code, payload)
  end

  # error message: invalid id (id must be a string of integer or integers separated by commas)
  defp invalid_id(conn, string_ids) do
    conn |> send(404, "invalid or empty ID: \"#{string_ids}\"")
  end

  # error message: Name.id not exist
  defp not_exist_id(conn, string_ids) do
    conn |> send(404, "resource with ID #{string_ids} not exist")
  end

  get "/" do
    map_params = Plug.Conn.fetch_query_params(conn).query_params

    if Map.has_key?(map_params, "id") do
      string_ids = Map.fetch!(map_params, "id")

      # check if string_ids only contains digits separated by commas
      if Regex.match?(~r{^\d+(,\d+)*$}, string_ids) do
        list_ids = String.split(string_ids, ",", trim: true)

        if list_ids != [] do
          # parse strings in list_ids into integers
          enum_ids =
            Enum.flat_map(list_ids, fn string_id ->
              case Integer.parse(string_id) do
                # transform to integer
                {int_id, _} -> [int_id]
                # skip the value
                :error -> []
              end
            end)

          if enum_ids != [] do
            # query Name if Name.id is in enum_ids
            query =
              from(n in Name,
                join: i in fragment("unnest(?::int[])", ^enum_ids),
                on: n.id == i,
                select: n
              )

            # send result if exist
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
        conn |> invalid_id(string_ids)
      end
    else
      # send all names when no id in_query params
      conn |> send(200, Repo.all(Name))
    end
  end

  match _ do
    conn |> send(404, "Error 404 Not Found")
  end
end
