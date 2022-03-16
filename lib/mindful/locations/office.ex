defmodule Mindful.Locations.Office do
  @moduledoc """
  The Office schema
  """
  use Mindful, :schema

  alias Mindful.Appointments.Appointment
  alias Mindful.Locations.State
  alias MindfulWeb.Helpers.Utils

  schema "offices" do
    field :city, :string
    field :description, :string
    field :name, :string
    field :slug, :string
    field :street, :string
    field :suite, :string
    field :zip, :string
    field :lat, :float
    field :lng, :float
    field :google_location_id, :string
    field :phone, :string, default: "(516) 407-8558"
    field :fax, :string, default: "(949) 419-3482"
    field :hours, :string, default: "Sunday - Friday: 8am - 6pm"
    field :email, :string, default: "hello@mindful.care"

    has_one :markdown_blob, Mindful.Content.MarkdownBlob
    belongs_to :state, State, foreign_key: :state_abbr, references: :abbr, type: :string
    has_many(:appointments, Appointment)

    many_to_many :providers, Mindful.Clinicians.Provider,
      join_through: "offices_providers",
      preload_order: [asc: :rank]

    timestamps()
  end

  @attrs ~w(name description street suite city slug state_abbr zip lat lng
  google_location_id phone fax hours email)a
  @create_attrs ~w(name description street suite city state_abbr zip lat lng
  google_location_id)a
  @edit_attrs ~w(name description street suite city state_abbr zip lat lng
  google_location_id phone fax hours email)a
  @required_attrs ~w(name description street city state_abbr zip lng)a

  def changeset(office, attrs) do
    office
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def create_changeset(office, attrs) do
    office
    |> cast(attrs, @create_attrs)
    |> validate_required(@required_attrs)
    |> validate_required(:lat, message: "Google Maps could not locate this address")
    |> add_slug()
    |> unsafe_validate_unique(:name, Repo)
    |> unique_constraint(:name)
  end

  def edit_changeset(office, attrs) do
    office
    |> cast(attrs, @edit_attrs)
    |> validate_required(@required_attrs)
    |> validate_required(:lat, message: "Google Maps could not validate this address")
    |> add_slug()
    |> unsafe_validate_unique(:name, Repo)
    |> unique_constraint(:name)
  end

  defp add_slug(changeset) do
    name = get_field(changeset, :name)

    if name do
      slug = Utils.slugified_name(name) <> "-psychiatry"
      put_change(changeset, :slug, slug)
    else
      changeset
    end
  end

  defimpl Phoenix.Param, for: Mindful.Locations.Office do
    def to_param(%{slug: slug}) do
      "#{slug}"
    end
  end
end
