defmodule Mindful.Content.TeamMember do
  @moduledoc """
  Mindful.Content.TeamMember module
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "team_members" do
    field :name, :string
    field :job_title, :string
    field :image_path, :string
    field :rank, :integer

    timestamps()
  end

  @required_fields ~w(name job_title image_path)a
  @optional_fields ~w(rank)a

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
