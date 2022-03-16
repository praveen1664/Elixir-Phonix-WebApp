defmodule Mindful.ChronoSchemas.DrchronoProcedure do
  @moduledoc """
  This is the schema for a procedure from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_procedures" do
    field :uuid, :integer
    field :appointment, :integer
    field :doctor, :integer
    field :code, :string
    field :procedure_type, :string
    field :adjustment, :float
    field :allowed, :float
    field :balance_ins, :float
    field :balance_pt, :float
    field :balance_total, :float
    field :billed, :float
    field :billing_status, :string
    field :description, :string
    field :expected_reimbursement, :float
    field :ins_total, :float
    field :ins1_paid, :float
    field :ins2_paid, :float
    field :ins3_paid, :float
    field :insurance_status, :string
    field :paid_total, :float
    field :patient, :integer
    field :posted_date, :utc_datetime
    field :price, :float
    field :pt_paid, :float
    field :service_date, :utc_datetime
  end
end
