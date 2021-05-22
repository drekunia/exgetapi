defmodule ExgetapiTest do
  import Ecto.Query
  use ExUnit.Case, async: true
  use Plug.Test
  alias Exgetapi.Router
  alias Exgetapi.Repo

  @opts Router.init([])

  test "Request without parameter id" do
    conn =
      :get
      |> conn("/")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "Request with single id" do
    conn =
      :get
      |> conn("/?id=2")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "Request with multiple ids" do
    id = Repo.aggregate(from(n in "names"), :count, :id) + 1

    conn =
      :get
      |> conn("/?id=1,3,#{id}")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "Request with invalid id" do
    conn =
      :get
      |> conn("/?id=xxx")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
  end

  test "Request with id not found" do
    id = Repo.aggregate(from(n in "names"), :count, :id) + 1

    conn =
      :get
      |> conn("/?id=#{id}")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
