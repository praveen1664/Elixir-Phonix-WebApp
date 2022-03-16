defmodule Mindful.Repo.Migrations.AlterPdfFieldForDrchronoAppointments do
  use Ecto.Migration

  def up do
    alter table(:drchrono_appointments) do
      modify :clinical_note_pdf, :text
    end
  end

  def down do
    alter table(:drchrono_appointments) do
      remove :clinical_note_pdf
      add :clinical_note_pdf, :string
    end
  end
end
