defmodule Mindful.ChronoSchemas.DrchronoAppointmentProfile do
  @moduledoc """
  This is the schema for an appointment profile from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_appointment_profiles" do
    field :uuid, :integer
    field :color, :string
    field :name, :string
    field :online_scheduling, :boolean
    field :doctor, :integer
    field :duration, :integer
    field :reason, :string
    field :sort_order, :integer
  end
end
