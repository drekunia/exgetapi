defmodule Exgetapi.Repo do
  use Ecto.Repo,
    otp_app: :exgetapi,
    adapter: Ecto.Adapters.Postgres
end
