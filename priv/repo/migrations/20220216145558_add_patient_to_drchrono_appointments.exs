defmodule Mindful.Repo.Migrations.AddPatientToDrchronoAppointments do
  use Ecto.Migration

  def up do
    alter table(:drchrono_appointments) do
      add :patient, :bigint
    end
  end

  def down do
    alter table(:drchrono_appointments) do
      remove :patient
    end
  end
end
