defmodule Mindful.Repo.Migrations.AddDateDiagnosisToProblems do
  use Ecto.Migration

  def up do
    alter table(:drchrono_problems) do
      add :date_diagnosis, :utc_datetime
    end
  end

  def down do
    alter table(:drchrono_problems) do
      remove :date_diagnosis
    end
  end
end
