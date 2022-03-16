defmodule Mindful.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :provider_id, references(:providers, on_delete: :delete_all), null: false
      add :office_id, references(:offices, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :recurring, :boolean, null: false, default: false
      add :virtual, :boolean, null: false, default: false
      add :start_at, :utc_datetime_usec, null: false
      add :end_at, :utc_datetime_usec, null: false
      add :time_zone, :string, null: false
      add :duration, :integer, null: false
      add :status, :string
      add :url, :string
      add :confirmed_at, :utc_datetime_usec
      add :canceled_at, :utc_datetime_usec
      add :notes, :text
      add :drchrono_appointment_id, :bigint, null: false

      timestamps()
    end

    create unique_index(:appointments, [:drchrono_appointment_id])
  end
end
