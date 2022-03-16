defmodule Mindful.Repo.Migrations.CreateOfficesProviders do
  use Ecto.Migration

  def change do
    create table(:offices_providers, primary_key: false) do
      add :office_id, references(:offices, on_delete: :delete_all)
      add :provider_id, references(:providers, on_delete: :delete_all)
    end

    create unique_index(:offices_providers, [:office_id, :provider_id])
  end
end
