defmodule Mindful.Locations.State do
  @moduledoc """
  Mindful.Locations.State module
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias MindfulWeb.Helpers.Utils
  alias Mindful.Accounts.User
  alias Mindful.Locations.Office
  alias Mindful.Prospects.Premarket

  schema "states" do
    field :abbr, :string
    field :description, :string
    field :image_path, :string
    field :name, :string
    field :slug, :string
    field :coming_soon, :boolean, default: false
    field :available_treatments, {:array, :string}, default: []

    has_many :users, User, foreign_key: :state_abbr, references: :abbr
    has_many :offices, Office, foreign_key: :state_abbr, references: :abbr
    has_many :premarkets, Premarket, foreign_key: :state_abbr, references: :abbr

    timestamps()
  end

  @attrs ~w(name abbr image_path description coming_soon available_treatments)a
  @edit_attrs ~w(image_path description coming_soon available_treatments)a

  def changeset(state, attrs) do
    state
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> add_slug_if_necessary()
    |> normalize_abbr()
    |> unsafe_validate_unique(:slug, Mindful.Repo)
    |> unique_constraint(:abbr)
    |> unique_constraint(:slug)
  end

  def edit_changeset(state, attrs) do
    state
    |> cast(attrs, @edit_attrs)
    |> validate_required(@edit_attrs)
  end

  defp add_slug_if_necessary(%{slug: _slug} = changeset), do: changeset

  defp add_slug_if_necessary(changeset) do
    name = get_field(changeset, :name)

    if name do
      Utils.slugified_name(name)
      |> (&put_change(changeset, :slug, &1)).()
    else
      changeset
    end
  end

  defp normalize_abbr(changeset) do
    abbr = get_change(changeset, :abbr)

    if abbr do
      downcased_abbr = String.downcase(abbr)
      changeset |> put_change(:abbr, downcased_abbr)
    else
      changeset
    end
  end

  defimpl Phoenix.Param, for: Mindful.Locations.State do
    def to_param(%{slug: slug}) do
      "#{slug}"
    end
  end
end
