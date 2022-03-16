defmodule Mindful.Locations do
  @moduledoc """
  The Locations context.
  """
  use Mindful, :context

  alias Mindful.Locations.{GoogleLocation, GoogleReview, Office, OfficeProvider, State}

  ### States

  def list_states(), do: State |> order_by(asc: :name) |> Repo.all()

  def get_state!(id), do: Repo.get!(State, id)

  @doc """
  Returns a state record by given an abbr.

  If not found return nil

  ## Examples

      iex> Locations.get_state_by_abbr("ny")
      iex> %Mindful.Locations.State{}

      iex> Locations.get_state_by_abbr("invalid")
      iex> nil

      iex> Locations.get_state_by_abbr(nil)
      iex> nil
  """
  @spec get_state_by_abbr(binary()) :: State.t()
  def get_state_by_abbr(abbr) when is_binary(abbr) do
    Repo.get_by(State, abbr: String.downcase(abbr))
  end

  def get_state_by_abbr(_), do: nil

  # Todo: Add test
  def get_state_by_slug(slug) when is_binary(slug),
    do: Repo.get_by(State, slug: String.downcase(slug))

  def get_state_by_slug(_), do: nil

  def get_state_by_slug!(slug) do
    slug = if is_binary(slug), do: String.downcase(slug), else: slug
    Repo.get_by!(State, slug: slug)
  end

  def create_state(attrs) do
    %State{}
    |> State.changeset(attrs)
    |> Repo.insert()
  end

  def update_state(%State{} = state, attrs) do
    state
    |> State.edit_changeset(attrs)
    |> Repo.update()
  end

  def delete_state(%State{} = state), do: Repo.delete(state)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking state changes.
  """
  def change_state(%State{} = state, attrs \\ %{}) do
    State.changeset(state, attrs)
  end

  def edit_state_changeset(%State{} = state, attrs \\ %{}) do
    State.edit_changeset(state, attrs)
  end

  ### Offices

  def list_offices, do: Office |> preload(:state) |> Repo.all()

  def get_office!(id), do: Repo.get!(Office, id)

  def get_office_by_slug!(slug) do
    Repo.get_by!(Office, slug: slug) |> Repo.preload(:providers)
  end

  @doc """
  Returns a list of all the offices that have the given state's abbreviation.
  """
  @spec list_offices_for_state(State.t() | String.t()) :: [Office.t()]
  def list_offices_for_state(%State{coming_soon: false, abbr: state_abbr}) do
    from(o in Office, where: o.state_abbr == ^state_abbr, order_by: o.name)
    |> Repo.all()
    |> Repo.preload(:providers)
  end

  def list_offices_for_state(state) when is_binary(state) do
    list_offices_for_state(%State{coming_soon: false, abbr: state})
  end

  def list_offices_for_state(_), do: []

  def create_office(attrs \\ %{}) do
    %Office{}
    |> Office.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_office(%Office{} = office, attrs) do
    office
    |> Office.edit_changeset(attrs)
    |> Repo.update()
  end

  def delete_office(%Office{} = office), do: Repo.delete(office)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking office changes.
  """
  def change_office(%Office{} = office, attrs \\ %{}) do
    Office.changeset(office, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking new office changes.
  """
  def new_change_office(%Office{} = office, attrs \\ %{}) do
    Office.create_changeset(office, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edit office changes.
  """
  def edit_change_office(%Office{} = office, attrs \\ %{}) do
    Office.edit_changeset(office, attrs)
  end

  @doc """
  Associate a provider with an office.
  """
  def assign_office_provider!(%Office{id: office_id}, %{id: provider_id}) do
    %OfficeProvider{}
    |> OfficeProvider.changeset(%{office_id: office_id, provider_id: provider_id})
    |> Repo.insert()
  end

  @doc """
  Delete an sssociation between a provider and an office.
  """
  def delete_office_provider!(%Office{id: office_id}, %{id: provider_id}) do
    OfficeProvider
    |> where([op], op.office_id == ^office_id)
    |> where([op], op.provider_id == ^provider_id)
    |> Repo.delete_all()
  end

  ### Google Locations and Reviews

  @doc """
  Delete all of the Google Locations in the database, and replace them with the new list of locations.
  """
  def delete_and_save_all_google_locations(locations) do
    {_, nil} = Repo.delete_all(GoogleLocation)
    {_, returned} = Repo.insert_all(GoogleLocation, locations, returning: [:location_id])
    returned
  end

  @doc """
  Delete all of the Google Reviews in the database, and replace them with the new list of reviews.
  """
  def delete_and_save_all_google_reviews(reviews) do
    {_, nil} = Repo.delete_all(GoogleReview)
    Repo.insert_all(GoogleReview, reviews)
  end

  def list_google_locations, do: Repo.all(GoogleLocation)

  def list_reviews_for_location(nil), do: []

  def list_reviews_for_location(location_id) do
    GoogleReview
    |> where([r], r.location_id == ^location_id)
    |> order_by([r], desc: r.created_at)
    |> Repo.all()
  end
end
