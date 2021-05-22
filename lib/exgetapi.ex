defmodule Exgetapi do
  import Ecto.Query
  import Plug.Conn
  require Protocol
  alias Exgetapi.Name
  alias Exgetapi.Repo

  # strip meta from Name in Jason.encode
  Protocol.derive(Jason.Encoder, Name, except: [:__meta__])

  # send json response
  defp respond(conn, code, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, payload)
  end

  # check if there's id in query_params
  def validate_id(conn) do
    map_params = fetch_query_params(conn).query_params

    # send all names when no id in_query params
    if Map.has_key?(map_params, "id"),
      do: conn |> match_regex(Map.fetch!(map_params, "id")),
      else: conn |> send_result(200, Repo.all(Name))
  end

  # not base path
  def error_path(conn), do: conn |> send_result(404, "Error 404 Not Found")

  # string match if only contains digits (separated by commas)
  defp match_regex(conn, string_ids) do
    if Regex.match?(~r{^\d+(,\d+)*$}, string_ids),
      do: conn |> enum_list_ids(String.split(string_ids, ",", trim: true)),
      else: conn |> invalid_id(string_ids)
  end

  # parse string_id in list_ids into ints and remove duplicates
  defp enum_list_ids(conn, list_ids) when list_ids != [] do
    enum_ids =
      Enum.uniq(
        Enum.flat_map(list_ids, fn string_id ->
          case Integer.parse(string_id) do
            # transform to integer
            {int_id, _} -> [int_id]
            # skip the value
            :error -> []
          end
        end)
      )

    query_enum_ids(conn, enum_ids)
  end

  # invalid string split
  defp enum_list_ids(conn, list_ids) when list_ids == [] do
    conn |> invalid_id(Enum.join(list_ids, ","))
  end

  # query when id in enum_ids
  defp query_enum_ids(conn, enum_ids) when enum_ids != [] do
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

  # dont query when invalid id in enum_ids
  defp query_enum_ids(conn, enum_ids) when enum_ids == [] do
    conn |> invalid_id(Enum.join(enum_ids, ","))
  end

  # send names if exist
  defp result(conn, _, names) when names != [] do
    conn |> send_result(200, names)
  end

  # dont send names when names with enum_ids as id not exist
  defp result(conn, enum_ids, names) when names == [] do
    conn |> not_exist_id(Enum.join(enum_ids, ","))
  end

  # send names record if all success
  defp send_result(conn, code, names) when is_list(names) do
    payload = Jason.encode!(%{"code" => code, "data" => names})

    conn |> respond(code, payload)
  end

  # send error message
  defp send_result(conn, code, message) when is_bitstring(message) do
    payload = Jason.encode!(%{"code" => code, "message" => message})

    conn |> respond(code, payload)
  end

  # error message: invalid id
  defp invalid_id(conn, string_ids) do
    conn |> send_result(400, "invalid or empty ID: \"#{string_ids}\"")
  end

  # error message: Name.id not exist
  defp not_exist_id(conn, string_ids) do
    conn |> send_result(404, "resource with ID #{string_ids} not exist")
  end
end
