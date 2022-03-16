defmodule Mindful.ChronoSchemas.DrchronoMedication do
  @moduledoc """
  This is the schema for a medication from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_medications" do
    field :uuid, :integer
    field :doctor, :integer
    field :patient, :integer
    field :appointment, :integer
    field :date_prescribed, :utc_datetime
    field :date_started_taking, :utc_datetime
    field :date_stopped_taking, :utc_datetime
    field :daw, :boolean
    field :dispense_quantity, :float
    field :dosage_quantity, :string
    field :dosage_unit, :string
    field :frequency, :string
    field :indication, :string
    field :name, :string
    field :ndc, :string
    field :notes, :string
    field :number_refills, :integer
    field :order_status, :string
    field :pharmacy_note, :string
    field :prn, :boolean
    field :route, :string
    field :rxnorm, :string
    field :signature_note, :string
    field :status, :string
  end
end
