defmodule Mindful.Repo.Migrations.AlterStateAddingAvailableTreatmentsColumn do
  use Ecto.Migration

  def up do
    alter table(:states) do
      add :available_treatments, {:array, :string}, default: []
    end
  end

  def down do
    alter table(:states) do
      remove :available_treatments
    end
  end
end
