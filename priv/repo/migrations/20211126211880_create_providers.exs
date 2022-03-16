defmodule Mindful.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :first_name, :citext
      add :last_name, :string
      add :job_title, :string
      add :credential_initials, :string
      add :image_path, :string
      add :about, :text
      add :details, :text
      add :slug, :string
      add :rank, :integer

      timestamps()
    end

    create unique_index(:providers, [:slug])
  end
end
