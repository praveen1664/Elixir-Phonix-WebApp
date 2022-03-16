defmodule Mindful.ChronoSchemas.DrchronoPatient do
  @moduledoc """
  This is the schema for a patient from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_patients" do
    field :uuid, :integer
    field :first_name, :string
    field :last_name, :string
    field :date_of_birth, :utc_datetime
    field :primary_care_physician, :string
    field :home_phone, :string
    field :cell_phone, :string
    field :office_phone, :string
    field :email, :string
    field :gender, :string
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    field :doctor, :integer
    field :copay, :float
    field :ethnicity, :string
    field :patient_status, :string
    field :race, :string
    field :date_of_first_appointment, :utc_datetime
    field :date_of_last_appointment, :utc_datetime
    field :referring_source, :string
    field :primary_insurance_payer_id, :string
    field :primary_insurance_company, :string
    field :primary_insurance_group_name, :string
    field :primary_insurance_plan_name, :string
    field :primary_insurance_is_subscriber_the_patient, :boolean
    field :primary_insurance_patient_relationship_to_subscriber, :string
    field :primary_insurance_subscriber_state, :string
    field :secondary_insurance_payer_id, :string
    field :secondary_insurance_company, :string
    field :secondary_insurance_group_name, :string
    field :secondary_insurance_plan_name, :string
    field :secondary_insurance_is_subscriber_the_patient, :boolean
    field :secondary_insurance_patient_relationship_to_subscriber, :string
    field :secondary_insurance_subscriber_state, :string
    field :referring_doctor_first_name, :string
    field :referring_doctor_last_name, :string
    field :referring_doctor_suffix, :string
    field :referring_doctor_npi, :string
    field :referring_doctor_email, :string
    field :referring_doctor_phone, :string
  end
end
