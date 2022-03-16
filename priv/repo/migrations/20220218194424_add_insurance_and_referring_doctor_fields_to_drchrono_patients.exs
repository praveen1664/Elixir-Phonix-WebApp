defmodule Mindful.Repo.Migrations.AddInsuranceAndReferringDoctorFieldsToDrchronoPatients do
  use Ecto.Migration

  def up do
    alter table(:drchrono_patients) do
      remove :primary_insurance_payer_name
      remove :referring_doctor

      add :primary_insurance_company, :string
      add :primary_insurance_group_name, :string
      add :primary_insurance_plan_name, :string
      add :primary_insurance_is_subscriber_the_patient, :boolean
      add :primary_insurance_patient_relationship_to_subscriber, :string
      add :primary_insurance_subscriber_state, :string

      add :secondary_insurance_payer_id, :string
      add :secondary_insurance_company, :string
      add :secondary_insurance_group_name, :string
      add :secondary_insurance_plan_name, :string
      add :secondary_insurance_is_subscriber_the_patient, :boolean
      add :secondary_insurance_patient_relationship_to_subscriber, :string
      add :secondary_insurance_subscriber_state, :string

      add :referring_doctor_first_name, :string
      add :referring_doctor_last_name, :string
      add :referring_doctor_suffix, :string
      add :referring_doctor_npi, :string
      add :referring_doctor_email, :string
      add :referring_doctor_phone, :string
    end
  end

  def down do
    alter table(:drchrono_patients) do
      add :primary_insurance_payer_name, :string
      add :referring_doctor, :string

      remove :primary_insurance_company
      remove :primary_insurance_group_name
      remove :primary_insurance_plan_name
      remove :primary_insurance_is_subscriber_the_patient
      remove :primary_insurance_patient_relationship_to_subscriber
      remove :primary_insurance_subscriber_state

      remove :secondary_insurance_payer_id
      remove :secondary_insurance_company
      remove :secondary_insurance_group_name
      remove :secondary_insurance_plan_name
      remove :secondary_insurance_is_subscriber_the_patient
      remove :secondary_insurance_patient_relationship_to_subscriber
      remove :secondary_insurance_subscriber_state

      remove :referring_doctor_first_name
      remove :referring_doctor_last_name
      remove :referring_doctor_suffix
      remove :referring_doctor_npi
      remove :referring_doctor_email
      remove :referring_doctor_phone
    end
  end
end
