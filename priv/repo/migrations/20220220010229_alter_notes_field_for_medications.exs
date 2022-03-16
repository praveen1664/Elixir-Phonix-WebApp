defmodule Mindful.Repo.Migrations.AlterNotesFieldForMedications do
  use Ecto.Migration

  def up do
    alter table(:drchrono_medications) do
      modify :notes, :text
    end
  end

  def down do
    alter table(:drchrono_medications) do
      remove :notes
      add :notes, :string
    end
  end
end
