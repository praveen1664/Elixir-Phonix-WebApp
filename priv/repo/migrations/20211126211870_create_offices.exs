defmodule Mindful.Repo.Migrations.CreateOffices do
  use Ecto.Migration

  def change do
    create table(:offices) do
      add :name, :citext
      add :slug, :string
      add :description, :text
      add :street, :string
      add :suite, :string
      add :city, :string
      add :state_abbr, :citext
      add :zip, :string
      add :lat, :float
      add :lng, :float
      add :google_location_id, :string
      add :phone, :string, default: "(516) 407-8558"
      add :fax, :string, default: "(949) 419-3482"
      add :hours, :string, default: "Sunday - Friday: 8am - 6pm"
      add :email, :string, default: "hello@mindful.care"

      timestamps()
    end

    create unique_index(:offices, [:name])
    create unique_index(:offices, [:slug])
    create index(:offices, [:state_abbr])
  end
end
