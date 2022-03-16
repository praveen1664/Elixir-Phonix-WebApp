defmodule Mindful.Repo.Migrations.AddApptIsBreakFieldToDrchronoAppointments do
  use Ecto.Migration

  def up do
    alter table(:drchrono_appointments) do
      add :appt_is_break, :boolean
    end
  end

  def down do
    alter table(:drchrono_appointments) do
      remove :appt_is_break
    end
  end
end
