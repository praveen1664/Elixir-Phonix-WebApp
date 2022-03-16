defmodule Mindful.Repo.Migrations.AddAddressToDrchronoPatients do
  use Ecto.Migration

  def up do
    alter table(:drchrono_patients) do
      add :address, :string
    end
  end

  def down do
    alter table(:drchrono_patients) do
      remove :address
    end
  end
end
