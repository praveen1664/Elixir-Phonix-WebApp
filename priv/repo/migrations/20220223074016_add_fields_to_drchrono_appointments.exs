defmodule Mindful.Repo.Migrations.AddFieldsToDrchronoAppointments do
  use Ecto.Migration

  def up do
    alter table(:drchrono_appointments) do
      add :recurring_appointment, :boolean
      add :base_recurring_appointment, :integer
      add :is_virtual_base, :boolean
      add :is_walk_in, :boolean
      add :allow_overlapping, :boolean
    end
  end

  def down do
    alter table(:drchrono_appointments) do
      remove :recurring_appointment
      remove :base_recurring_appointment
      remove :is_virtual_base
      remove :is_walk_in
      remove :allow_overlapping
    end
  end
end
