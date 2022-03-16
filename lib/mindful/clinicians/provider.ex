defmodule Mindful.Clinicians.Provider do
  @moduledoc """
  The Provider schema
  """
  use Mindful, :schema

  alias Mindful.Appointments.Appointment
  alias MindfulWeb.Helpers.Utils

  schema "providers" do
    field :first_name, :string
    field :last_name, :string
    field :credential_initials, :string
    field :job_title, :string
    field :image_path, :string
    field :about, :string
    field :details, :string
    field :slug, :string
    field :rank, :integer

    many_to_many :offices, Mindful.Locations.Office, join_through: "offices_providers"
    has_many(:appointments, Appointment)

    timestamps()
  end

  @required_fields ~w(first_name last_name credential_initials job_title image_path about)a
  @optional_fields ~w(details rank slug)a

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> add_slug_if_necessary()
    |> unsafe_validate_unique(:slug, Mindful.Repo)
    |> unique_constraint(:slug)
  end

  @doc """
  Changeset to use for editing/updating a provider.
  """
  def edit_changeset(provider, attrs) do
    provider
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> update_slug()
    |> unsafe_validate_unique(:slug, Mindful.Repo)
    |> unique_constraint(:slug)
  end

  @doc """
  Changeset to use for editing/updating a provider's details field.
  """
  def edit_details_changeset(provider, attrs) do
    provider |> cast(attrs, [:details])
  end

  defp add_slug_if_necessary(%{slug: _slug} = changeset), do: changeset

  defp add_slug_if_necessary(changeset) do
    name = get_field(changeset, :first_name)

    if name do
      Utils.slugified_name(name)
      |> (&put_change(changeset, :slug, &1)).()
    else
      changeset
    end
  end

  defp update_slug(changeset) do
    original_name = changeset.data.first_name
    name = get_field(changeset, :first_name)

    if original_name != name do
      Utils.slugified_name(name)
      |> (&put_change(changeset, :slug, &1)).()
    else
      changeset
    end
  end

  defimpl Phoenix.Param, for: Mindful.Clinicians.Provider do
    def to_param(%{slug: slug}) do
      "#{slug}"
    end
  end
end
