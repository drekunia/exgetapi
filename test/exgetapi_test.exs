defmodule ExgetapiTest do
  import Ecto.Query
  use ExUnit.Case, async: true
  use Plug.Test
  alias Exgetapi.Router
  alias Exgetapi.Repo

  @opts Router.init([])

  # get request
  defp conn_get(params) do
    :get
    |> Plug.Test.conn(params)
    |> Router.call(@opts)
  end

  # count name records
  defp name_count, do: Repo.aggregate(from(n in "names"), :count, :id)

  # generate random name.id
  defp random_id, do: Enum.random(1..name_count())

  # get data list
  defp list_resp(conn) do
    %{"data" => list} = Jason.decode!(conn.resp_body)
    list
  end

  # single id data list
  defp single_record(conn) do
    [record] = list_resp(conn)
    record
  end

  # response data list count
  defp list_count(conn), do: Enum.count(list_resp(conn))

  test "Request without parameter id" do
    conn = conn_get("/")

    assert conn.state == :sent
    assert conn.status == 200
    assert list_count(conn) == name_count()
  end

  test "Request with single id" do
    id = random_id()
    conn = conn_get("/?id=#{id}")
    s = single_record(conn)

    assert conn.state == :sent
    assert conn.status == 200
    assert s["id"] == id
  end

  test "Request with multiple ids" do
    # 3 ids provided, get 2 records
    # 1 id is not exist
    id = [1, 2, name_count() + 1]
    conn = conn_get("/?id=#{Enum.join(id, ",")}")

    assert conn.state == :sent
    assert conn.status == 200
    assert list_count(conn) == 2
  end

  test "Request with invalid id" do
    conn = conn_get("/?id=xxx")

    assert conn.state == :sent
    assert conn.status == 400
  end

  test "Request with id not found" do
    id = name_count() + 1
    conn = conn_get("/?id=#{id}")

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "Request with empty id" do
    conn = conn_get("/?id=")

    assert conn.state == :sent
    assert conn.status == 400
  end

  test "Request with duplicate ids" do
    id = random_id()
    # duplicate single random_id 1-10 times
    conn = conn_get("/?id=#{Enum.join(Enum.map(1..10, fn _ -> id end), ",")}")
    s = single_record(conn)

    assert conn.state == :sent
    assert conn.status == 200
    assert s["id"] == id
  end

  test "Request with invalid id string and numbers separated by commas" do
    conn = conn_get("/?id=xxx,yyy,1,#{random_id()}")

    assert conn.state == :sent
    assert conn.status == 400
  end

  test "Request with different parameters and single id" do
    id = random_id()
    conn = conn_get("/?foo=1&bar=2&id=#{id}")
    s = single_record(conn)

    assert conn.state == :sent
    assert conn.status == 200
    assert s["id"] == id
  end

  test "Request with trailing commas after numbers" do
    # generate random_id 1-10 times and add comma at the end
    conn = conn_get("/?id=#{Enum.join(Enum.map(1..10, fn _ -> random_id() end), ",")},")

    assert conn.state == :sent
    assert conn.status == 400
  end
end
