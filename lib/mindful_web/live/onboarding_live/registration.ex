defmodule MindfulWeb.OnboardingLive.Registration do
  @moduledoc """
  MindfulWeb.OnboardingLive.Registration module to handle news users registration
  """
  use MindfulWeb, :live_view

  import MindfulWeb.OnboardingLive.RegistrationView

  alias Mindful.Accounts
  alias Mindful.Accounts.User
  alias Mindful.Locations
  alias MindfulWeb.Helpers.Atomify, as: Atomify
  alias MindfulWeb.OnboardingLive.ErrorHandler

  @doc """
  Mounts the initial variables when request /registration for the first time.

  Socket contain all relevant information that will be send to the view.

  Returns {:noreply, socket}
  """
  def mount(_params, session, socket) do
    {:ok, socket} = assign_defaults(session, socket)
    changeset = prepare_new_onboarding_registration_user_changeset(%{})

    socket =
      socket
      |> assign(:current_step, 1)
      |> assign(:page_title, "Registration | Mindful Care")
      |> assign(:changeset, changeset)
      |> assign(:errors, %ErrorHandler{})
      |> assign(:redirect_to_locations_path, false)
      |> assign(:selected_treatments, [])
      |> assign(:available_treatments, [])

    {:ok, socket}
  end

  @doc """
  Handle calls to next_step events

  Check if the current state of the data is allowed to move to the next step or needs to raise and error.

  Returns {:noreply, socket}
  """
  def handle_event("next_step", _params, socket) do
    current_step = socket.assigns.current_step
    changeset = socket.assigns.changeset

    {invalid_step?, errors} =
      case current_step do
        1 -> ErrorHandler.extract(:urgency, changeset)
        2 -> ErrorHandler.extract(:state_abbr, changeset)
        3 -> ErrorHandler.extract(:treatments, changeset)
        _ -> {false, %ErrorHandler{}}
      end

    new_step = if invalid_step?, do: current_step, else: current_step + 1

    socket =
      socket
      |> assign(:current_step, new_step)
      |> assign(:errors, errors)

    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => %{"state_abbr" => "other_state"}}, socket) do
    changes = socket.assigns.changeset.changes
    user_params = %{state_abbr: "other_state"}

    changeset =
      prepare_new_onboarding_registration_user_changeset(Map.merge(changes, user_params))

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:redirect_to_locations_path, true)
      |> assign(:errors, %ErrorHandler{})

    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => %{"state_abbr" => state_abbr}}, socket) do
    changes = socket.assigns.changeset.changes
    user_params = %{state_abbr: state_abbr}
    state = Locations.get_state_by_abbr(state_abbr)

    changeset =
      prepare_new_onboarding_registration_user_changeset(Map.merge(changes, user_params))

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:state, state)
      |> assign(:available_treatments, state.available_treatments)
      |> assign(:errors, %ErrorHandler{})

    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => %{"treatments" => treatments}}, socket) do
    treatments =
      treatments
      |> Enum.reduce([], fn {key, value}, acc ->
        if value == "true" do
          [key | acc]
        else
          acc
        end
      end)

    changes = socket.assigns.changeset.changes

    changeset =
      prepare_new_onboarding_registration_user_changeset(
        Map.merge(changes, %{treatments: treatments})
      )

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:selected_treatments, treatments)
      |> assign(:errors, %ErrorHandler{})

    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changes = socket.assigns.changeset.changes
    user_params = Atomify.keys_to_atoms(user_params)

    changeset =
      prepare_new_onboarding_registration_user_changeset(Map.merge(changes, user_params))

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:errors, %ErrorHandler{})
      |> assign(:redirect_to_locations_path, false)

    {:noreply, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    changes = socket.assigns.changeset.changes
    user_params = Atomify.keys_to_atoms(user_params)

    changeset =
      prepare_new_onboarding_registration_user_changeset(Map.merge(changes, user_params))

    case Accounts.save_onboarding_registration_user(changeset.changes) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &MindfulWeb.Router.Helpers.user_confirmation_url(socket, :edit, &1)
          )

        path_opts = [user_id: user.id, state: socket.assigns.state.abbr]

        # TODO: create token to handle redirect sign in.
        {:noreply,
         push_redirect(socket,
           to: Routes.onboarding_schedule_path(socket, :registration, path_opts)
         )}

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Keyword.keys()
          |> Enum.map(fn field ->
            {_, error_handler} = ErrorHandler.extract(field, changeset)

            {field, error_handler}
          end)

        {:noreply, assign(socket, :errors, %ErrorHandler{messages: errors})}
    end
  end

  defp prepare_new_onboarding_registration_user_changeset(params) do
    %User{}
    |> Accounts.new_onboarding_registration_user(params)
    |> Map.put(:action, :insert)
  end
end
