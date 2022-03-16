defmodule Mindful.Repo.Migrations.CreateGoogleLocations do
  use Ecto.Migration

  def change do
    create table(:google_locations) do
      add :location_id, :string
      add :title, :string
      add :address, :string
    end
  end
end
