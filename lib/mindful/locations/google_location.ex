defmodule Mindful.Locations.GoogleLocation do
  @moduledoc """
  Mindful.Locations.GoogleLocation module
  """

  use Ecto.Schema

  schema "google_locations" do
    field :location_id, :string
    field :title, :string
    field :address, :string
  end
end
