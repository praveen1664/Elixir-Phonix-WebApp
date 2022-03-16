defmodule Mindful.Repo.Migrations.AlterDrchronoTables do
  use Ecto.Migration

  def up do
    alter table(:drchrono_appointments) do
      remove :uuid
      remove :scheduled_time
      remove :created_at
      add :uuid, :bigint
      add :scheduled_time, :utc_datetime
      add :created_at, :utc_datetime

      add :clinical_note_locked, :boolean
      add :clinical_note_pdf, :string
      add :clinical_note_updated_at, :utc_datetime
    end

    create unique_index(:drchrono_appointments, [:uuid])

    alter table(:drchrono_line_items) do
      remove :uuid
      remove :adjustment
      remove :allowed
      remove :balance_ins
      remove :balance_pt
      remove :balance_total
      remove :billed
      remove :expected_reimbursement
      remove :ins_total
      remove :ins1_paid
      remove :ins2_paid
      remove :ins3_paid
      remove :paid_total
      remove :price
      remove :pt_paid
      remove :posted_date
      remove :quantity
      remove :service_date

      add :uuid, :bigint
      add :adjustment, :float
      add :allowed, :float
      add :balance_ins, :float
      add :balance_pt, :float
      add :balance_total, :float
      add :billed, :float
      add :expected_reimbursement, :float
      add :ins_total, :float
      add :ins1_paid, :float
      add :ins2_paid, :float
      add :ins3_paid, :float
      add :paid_total, :float
      add :price, :float
      add :pt_paid, :float
      add :posted_date, :utc_datetime
      add :quantity, :float
      add :service_date, :utc_datetime
    end

    create unique_index(:drchrono_line_items, [:uuid])

    alter table(:drchrono_patients) do
      remove :uuid
      remove :date_of_birth
      remove :copay
      remove :date_of_first_appointment
      remove :date_of_last_appointment

      add :uuid, :bigint
      add :date_of_birth, :utc_datetime
      add :copay, :float
      add :date_of_first_appointment, :utc_datetime
      add :date_of_last_appointment, :utc_datetime
      remove :date_of_next_appointment
    end

    create unique_index(:drchrono_patients, [:uuid])

    alter table(:drchrono_procedures) do
      remove :uuid
      remove :paid_total
      remove :posted_date
      remove :service_date

      add :uuid, :bigint
      add :paid_total, :float
      add :posted_date, :utc_datetime
      add :service_date, :utc_datetime
    end

    create unique_index(:drchrono_procedures, [:uuid])

    alter table(:drchrono_offices) do
      add :start_time, :string
      add :end_time, :string
    end
  end

  def down do
    alter table(:drchrono_appointments) do
      remove :uuid
      remove :scheduled_time
      remove :created_at
      add :uuid, :string
      add :scheduled_time, :string
      add :created_at, :string

      remove :clinical_note_locked
      remove :clinical_note_pdf
      remove :clinical_note_updated_at
    end

    create unique_index(:drchrono_appointments, [:uuid])

    alter table(:drchrono_line_items) do
      remove :uuid
      remove :adjustment
      remove :allowed
      remove :balance_ins
      remove :balance_pt
      remove :balance_total
      remove :billed
      remove :expected_reimbursement
      remove :ins_total
      remove :ins1_paid
      remove :ins2_paid
      remove :ins3_paid
      remove :paid_total
      remove :price
      remove :pt_paid
      remove :posted_date
      remove :quantity
      remove :service_date

      add :uuid, :integer
      add :adjustment, :string
      add :allowed, :string
      add :balance_ins, :string
      add :balance_pt, :string
      add :balance_total, :string
      add :billed, :string
      add :expected_reimbursement, :string
      add :ins_total, :string
      add :ins1_paid, :string
      add :ins2_paid, :string
      add :ins3_paid, :string
      add :paid_total, :string
      add :price, :string
      add :pt_paid, :string
      add :posted_date, :string
      add :quantity, :string
      add :service_date, :string
    end

    create unique_index(:drchrono_line_items, [:uuid])

    alter table(:drchrono_patients) do
      remove :uuid
      remove :date_of_birth
      remove :copay
      remove :date_of_first_appointment
      remove :date_of_last_appointment

      add :uuid, :integer
      add :date_of_birth, :string
      add :copay, :string
      add :date_of_first_appointment, :string
      add :date_of_last_appointment, :string
      add :date_of_next_appointment, :string
    end

    create unique_index(:drchrono_patients, [:uuid])

    alter table(:drchrono_procedures) do
      remove :uuid
      remove :paid_total
      remove :posted_date
      remove :service_date

      add :uuid, :integer
      add :paid_total, :string
      add :posted_date, :string
      add :service_date, :string
    end

    create unique_index(:drchrono_procedures, [:uuid])

    alter table(:drchrono_offices) do
      remove :start_time
      remove :end_time
    end
  end
end
