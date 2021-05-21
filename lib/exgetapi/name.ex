defmodule Exgetapi.Name do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}

  schema "names" do
    field(:name, :string)
  end
end
