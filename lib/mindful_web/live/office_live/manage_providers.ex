defmodule MindfulWeb.OfficeLive.ManageProviders do
  @moduledoc """
  MindfulWeb.OfficeLive.ManageProviders module
  """

  use MindfulWeb, :live_view

  alias Mindful.Locations
  alias Mindful.Clinicians

  def mount(%{"slug" => slug, "o_slug" => office_slug}, session, socket) do
    {:ok, socket} = assign_defaults(session, socket)
    state = Locations.get_state_by_slug!(slug)
    office = Locations.get_office_by_slug!(office_slug)
    pool = (Clinicians.list_providers() -- office.providers) |> Enum.sort_by(& &1.first_name)

    {:ok,
     assign(socket,
       state: state,
       office: office,
       providers: office.providers,
       pool: pool,
       page_title: "Manage Providers at #{office.name} | Call a Dev"
     )}
  end

  def handle_event("add-provider" <> id, _params, socket) do
    provider = Clinicians.get_provider!(id)
    Locations.assign_office_provider!(socket.assigns.office, provider)
    pool = Enum.reject(socket.assigns.pool, &(&1.id == provider.id))
    providers = [provider | socket.assigns.providers]

    {:noreply, assign(socket, providers: providers, pool: pool)}
  end

  def handle_event("remove-provider" <> id, _params, socket) do
    provider = Clinicians.get_provider!(id)
    Locations.delete_office_provider!(socket.assigns.office, provider)
    pool = [provider | socket.assigns.pool]
    providers = Enum.reject(socket.assigns.providers, &(&1.id == provider.id))

    {:noreply, assign(socket, providers: providers, pool: pool)}
  end
end
