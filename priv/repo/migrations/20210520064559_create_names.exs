defmodule Exgetapi.Repo.Migrations.CreateNames do
  use Ecto.Migration

  def change do
    create table(:names) do
      add :name, :string
    end
  end
end
