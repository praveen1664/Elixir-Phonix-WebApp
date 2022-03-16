defmodule Mindful.Repo.Migrations.CreateDrcrhonoAppointmentProfiles do
  use Ecto.Migration

  def change do
    create table(:drchrono_appointment_profiles) do
      # This UUID is the id of the appointment in drchrono
      add :uuid, :integer
      add :color, :string
      add :name, :string
      add :online_scheduling, :boolean
      add :doctor, :integer
      add :duration, :integer
      add :reason, :string
      add :sort_order, :integer
    end

    create unique_index(:drchrono_appointment_profiles, [:uuid])
  end
end
