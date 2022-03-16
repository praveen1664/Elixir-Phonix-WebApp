defmodule Mindful.Repo.Migrations.CreateGoogleReviews do
  use Ecto.Migration

  def change do
    create table(:google_reviews) do
      add :location_id, :string
      add :name, :string
      add :rating, :integer
      add :comment, :text
      add :created_at, :utc_datetime
    end

    create index(:google_reviews, [:location_id])
  end
end
