defmodule Mindful.Prospects.Invite do
  @moduledoc """
  Mindful.Prospects.Premarket module
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :reason, :string
    field :to, :string
    field :created_by, :string

    timestamps()
  end

  @attrs ~w(reason to created_by)a

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
