defmodule Mindful.ChronoSchemas.DrchronoProblem do
  @moduledoc """
  This is the schema for a problem from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_problems" do
    field :uuid, :integer
    field :doctor, :integer
    field :patient, :integer
    field :date_changed, :utc_datetime
    field :date_diagnosis, :utc_datetime
    field :date_onset, :utc_datetime
    field :description, :string
    field :icd_code, :string
    field :info_url, :string
    field :name, :string
    field :notes, :string
    field :snomed_ct_code, :string
    field :status, :string
  end
end
