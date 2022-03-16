defmodule Mindful.JazzhrSchemas.JazzhrJob do
  @moduledoc """
  This is the schema for a job from the Jazzhr API.
  """

  use Ecto.Schema

  schema "jazzhr_jobs" do
    field :uuid, :string
    field :title, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :department, :string
    field :original_open_date, :utc_datetime
    field :type, :string
    field :status, :string
    field :hiring_lead, :string
  end
end
