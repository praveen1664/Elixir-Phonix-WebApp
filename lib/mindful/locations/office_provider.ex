defmodule Mindful.Locations.OfficeProvider do
  @moduledoc """
  Mindful.Locations.OfficeProvider module
  """

  use Ecto.Schema

  @primary_key false
  schema "offices_providers" do
    belongs_to :office, Mindful.Locations.Office
    belongs_to :provider, Mindful.Clinicians.Provider
  end

  @attrs ~w(office_id provider_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @attrs)
    |> Ecto.Changeset.validate_required(@attrs)

    # |> Ecto.Changeset.unique_constraint(:office_id,
    #   name: :offices_providers_office_id_provider_id_index
    # )
    # todo: fix unique constraint validation
  end
end
