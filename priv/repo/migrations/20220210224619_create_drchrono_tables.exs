defmodule Mindful.Repo.Migrations.CreateDrchronoTables do
  use Ecto.Migration

  def change do
    create table(:drchrono_patients) do
      # This UUID is the id of the patient in drchrono
      add :uuid, :integer
      add :first_name, :string
      add :last_name, :string
      add :date_of_birth, :string
      add :primary_care_physician, :string
      add :home_phone, :string
      add :cell_phone, :string
      add :office_phone, :string
      add :email, :citext
      add :gender, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
      add :doctor, :integer
      add :copay, :string
      add :ethnicity, :string
      add :patient_status, :string
      add :race, :string
      add :date_of_first_appointment, :string
      add :date_of_last_appointment, :string
      add :date_of_next_appointment, :string
      add :primary_insurance_payer_id, :string
      add :primary_insurance_payer_name, :string
      add :referring_doctor, :string
      add :referring_source, :string
    end

    create unique_index(:drchrono_patients, [:uuid])

    create table(:drchrono_appointments) do
      # This UUID is the id of the appointment in drchrono
      add :uuid, :string
      add :duration, :integer
      add :scheduled_time, :string
      add :created_at, :string
      add :doctor, :integer
      add :office, :integer
      add :exam_room, :integer
      add :profile, :integer
      add :reason, :string
      add :status, :string
    end

    create unique_index(:drchrono_appointments, [:uuid])

    create table(:drchrono_doctors) do
      # This UUID is the id of the doctor in drchrono
      add :uuid, :integer
      add :first_name, :string
      add :last_name, :string
      add :job_title, :string
      add :specialty, :string
    end

    create unique_index(:drchrono_doctors, [:uuid])

    create table(:drchrono_offices) do
      # This UUID is the id of the office in drchrono
      add :uuid, :integer
      add :name, :string
      add :address, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
    end

    create unique_index(:drchrono_offices, [:uuid])

    create table(:drchrono_procedures) do
      # This UUID is the id of the procedure in drchrono
      add :uuid, :integer
      add :appointment, :integer
      add :doctor, :integer
      add :code, :string
      add :procedure_type, :string
      add :adjustment, :float
      add :allowed, :float
      add :balance_ins, :float
      add :balance_pt, :float
      add :balance_total, :float
      add :billed, :float
      add :billing_status, :string
      add :description, :string
      add :expected_reimbursement, :float
      add :ins_total, :float
      add :ins1_paid, :float
      add :ins2_paid, :float
      add :ins3_paid, :float
      add :insurance_status, :string
      add :paid_total, :string
      add :patient, :integer
      add :posted_date, :string
      add :price, :float
      add :pt_paid, :float
      add :service_date, :string
    end

    create unique_index(:drchrono_procedures, [:uuid])

    create table(:drchrono_line_items) do
      # This UUID is the id of the line item in drchrono
      add :uuid, :integer
      add :appointment, :integer
      add :code, :string
      add :procedure_type, :string
      add :adjustment, :string
      add :allowed, :string
      add :balance_ins, :string
      add :balance_pt, :string
      add :balance_total, :string
      add :billed, :string
      add :billing_status, :string
      add :denied_flag, :boolean
      add :description, :string
      add :doctor, :integer
      add :expected_reimbursement, :string
      add :ins_total, :string
      add :ins1_paid, :string
      add :ins2_paid, :string
      add :ins3_paid, :string
      add :insurance_status, :string
      add :paid_total, :string
      add :patient, :integer
      add :posted_date, :string
      add :price, :string
      add :pt_paid, :string
      add :quantity, :string
      add :units, :string
      add :service_date, :string
    end

    create unique_index(:drchrono_line_items, [:uuid])
  end
end
