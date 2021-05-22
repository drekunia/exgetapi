defmodule ExgetapiTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "Getting data" do
    conn = :get |> conn("/")
    assert conn.state == :sent
    assert conn.status == 200
  end
end
