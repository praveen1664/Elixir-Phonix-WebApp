defmodule Mindful.Repo.Migrations.CreatePremarkets do
  use Ecto.Migration

  def change do
    create table(:premarkets) do
      add :email, :string
      add :state_abbr, :string

      timestamps()
    end
  end
end
