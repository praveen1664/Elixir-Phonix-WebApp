defmodule Mindful.ChronoSchemas.DrchronoOffice do
  @moduledoc """
  This is the schema for an office from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_offices" do
    field :uuid, :integer
    field :name, :string
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    field :start_time, :string
    field :end_time, :string
  end
end
