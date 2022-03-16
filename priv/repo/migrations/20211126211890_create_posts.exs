defmodule Mindful.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :pic_path, :string
      add :title, :string
      add :subtitle, :string
      add :body, :text
      add :slug, :string, null: false
      add :published_at, :utc_datetime

      timestamps()
    end

    create unique_index(:posts, [:slug])
  end
end
