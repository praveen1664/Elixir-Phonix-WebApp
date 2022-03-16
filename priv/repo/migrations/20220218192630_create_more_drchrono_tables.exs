defmodule Mindful.Repo.Migrations.CreateMoreDrchronoTables do
  use Ecto.Migration

  def change do
    create table(:drchrono_medications) do
      # This UUID is the id of the medication in drchrono
      add :uuid, :integer
      add :doctor, :integer
      add :patient, :integer
      add :appointment, :integer
      add :date_prescribed, :utc_datetime
      add :date_started_taking, :utc_datetime
      add :date_stopped_taking, :utc_datetime
      add :daw, :boolean
      add :dispense_quantity, :float
      add :dosage_quantity, :string
      add :dosage_unit, :string
      add :frequency, :string
      add :indication, :string
      add :name, :string
      add :ndc, :string
      add :notes, :string
      add :number_refills, :integer
      add :order_status, :string
      add :pharmacy_note, :string
      add :prn, :boolean
      add :route, :string
      add :rxnorm, :string
      add :signature_note, :string
      add :status, :string
    end

    create unique_index(:drchrono_medications, [:uuid])

    create table(:drchrono_problems) do
      # This UUID is the id of the medication in drchrono
      add :uuid, :integer
      add :doctor, :integer
      add :patient, :integer
      add :date_changed, :utc_datetime
      add :date_onset, :utc_datetime
      add :description, :string
      add :icd_code, :string
      add :info_url, :string
      add :name, :string
      add :notes, :string
      add :snomed_ct_code, :string
      add :status, :string
    end

    create unique_index(:drchrono_problems, [:uuid])
  end
end
