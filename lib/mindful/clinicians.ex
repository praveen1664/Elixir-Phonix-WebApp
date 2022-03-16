defmodule Mindful.Clinicians do
  @moduledoc """
  The Clinicians context.
  """

  import Ecto.Query
  alias Mindful.Repo
  alias Mindful.Clinicians.Provider

  def list_providers do
    Provider
    |> order_by(asc: :rank)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  def get_provider!(id), do: Repo.get!(Provider, id)

  def get_provider_by_slug(slug) do
    slug = String.downcase(slug)

    Provider
    |> preload(offices: :state)
    |> Repo.get_by(slug: slug)
  end

  def create_provider(attrs) do
    %Provider{}
    |> Provider.changeset(attrs)
    |> Repo.insert()
  end

  def update_provider(%Provider{} = provider, attrs) do
    provider
    |> Provider.edit_changeset(attrs)
    |> Repo.update()
  end

  def update_provider_details(%Provider{} = provider, attrs) do
    provider
    |> Provider.edit_details_changeset(attrs)
    |> Repo.update()
  end

  def delete_provider(%Provider{} = provider), do: Repo.delete(provider)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking provider changes.
  """
  def change_provider(%Provider{} = provider, attrs \\ %{}) do
    Provider.changeset(provider, attrs)
  end

  def edit_provider_changeset(%Provider{} = provider, attrs \\ %{}) do
    Provider.edit_changeset(provider, attrs)
  end

  def edit_provider_details_changeset(%Provider{} = provider, attrs \\ %{}) do
    Provider.edit_details_changeset(provider, attrs)
  end
end
