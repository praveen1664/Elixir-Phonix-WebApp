defmodule Mindful.Repo.Migrations.CreateStates do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :name, :string
      add :abbr, :citext, null: false
      add :image_path, :string
      add :description, :text
      add :slug, :string, null: false
      add :coming_soon, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:states, [:abbr])
    create unique_index(:states, [:slug])
  end
end
