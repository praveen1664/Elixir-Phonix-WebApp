defmodule MindfulWeb.OnboardingLive.Schedule do
  @moduledoc """
  Handles new user's first appointment scheduling.
  """
  use MindfulWeb, :live_view

  alias Mindful.Live.Components.Office
  alias Mindful.Live.Components.Provider
  alias Mindful.Locations

  @doc """
  Mounts and sets initial state
  """
  def mount(%{"state" => state}, session, socket) do
    {:ok, socket} = assign_defaults(session, socket)

    offices = Locations.list_offices_for_state(state)

    socket =
      socket
      |> assign(:page_title, "Registration - Schedule | Mindful Care")
      |> assign(:step, "select_office")
      |> assign(:state, state)
      |> assign(:offices, offices)

    {:ok, assign(socket, :offices, offices)}
  end

  def handle_event("back", %{"back" => step}, socket) do
    {:noreply, assign(socket, :step, step)}
  end

  def handle_event("select_office", %{"office_id" => id}, socket) do
    selected_office = Enum.find(socket.assigns.offices, fn off -> off.id == id end)
    providers = Enum.sort(selected_office.providers, &(&1.rank < &2.rank))

    socket =
      socket
      |> assign(:selected_office, selected_office)
      |> assign(:providers, providers)
      |> assign(:step, "select_provider")

    {:noreply, socket}
  end

  def handle_event("select_provider", %{"provider_id" => id}, socket) do
    selected_provider =
      Enum.find(socket.assigns.selected_office.providers, fn prov -> prov.id == id end)

    socket =
      socket
      |> assign(:selected_provider, selected_provider)
      |> assign(:step, "select_schedule")

    {:noreply, socket}
  end
end
