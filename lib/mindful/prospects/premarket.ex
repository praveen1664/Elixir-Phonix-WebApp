defmodule Mindful.Prospects.Premarket do
  @moduledoc """
  Mindful.Prospects.Premarket module
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Mindful.Locations.State

  schema "premarkets" do
    field :email, :string
    belongs_to :state, State, foreign_key: :state_abbr, references: :abbr, type: :string

    timestamps()
  end

  @attrs ~w(email state_abbr)a

  def changeset(premarket, attrs) do
    premarket
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
