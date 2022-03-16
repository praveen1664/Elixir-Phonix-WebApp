defmodule Mindful.Repo.Migrations.CreateMarkdownBlobs do
  use Ecto.Migration

  def change do
    create table(:markdown_blobs) do
      add :body, :text

      add :office_id, references(:offices, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:markdown_blobs, [:office_id])
  end
end
