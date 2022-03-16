defmodule Mindful.Locations.GoogleReview do
  @moduledoc """
  Mindful.Locations.GoogleReview module
  """

  use Ecto.Schema

  schema "google_reviews" do
    field :location_id, :string
    field :name, :string
    field :rating, :integer
    field :comment, :string
    field :created_at, :utc_datetime
  end
end
