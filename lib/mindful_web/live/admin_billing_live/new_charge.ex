defmodule MindfulWeb.AdminBillingLive.NewCharge do
  @moduledoc """
  MindfulWeb.AdminBillingLive.NewCharge module
  """

  use MindfulWeb, :live_view

  alias Mindful.Accounts
  alias MindfulWeb.DrchronoAdapter

  def mount(params, session, socket) do
    {:ok, socket} = assign_defaults(session, socket)

    case params do
      %{"code" => code} ->
        res = DrchronoAdapter.exchange_auth_code(code)

        case res do
          data when is_map(data) ->
            user = Accounts.save_chrono_auth_info!(socket.assigns.current_user, data)
            if user.superadmin, do: MindfulWeb.Services.TokensCache.store_drchrono_token(data)

            {:ok,
             assign(socket,
               current_user: user,
               drchrono_redirect_url: nil,
               auth_error: nil,
               patient_error: nil,
               patient_name: nil,
               patient_email: nil,
               patient_user: nil,
               past_invite: nil,
               charge_amount: nil,
               amount_error: nil,
               pay_status: nil,
               pay_error: nil,
               page_title: "Create a new charge for a patient | Mindful Care"
             )}

          error when is_binary(error) ->
            {:ok,
             assign(socket,
               drchrono_redirect_url: drchrono_redirect_url(socket.assigns.current_user),
               auth_error: "Dr. Chrono error message: " <> error,
               patient_error: nil,
               patient_name: nil,
               patient_email: nil,
               patient_user: nil,
               past_invite: nil,
               charge_amount: nil,
               amount_error: nil,
               pay_status: nil,
               pay_error: nil,
               page_title: "Create a new charge for a patient | Mindful Care"
             )}
        end

      %{"error" => error} ->
        {:ok,
         assign(socket,
           drchrono_redirect_url: drchrono_redirect_url(socket.assigns.current_user),
           auth_error: "Dr. Chrono error message: " <> error,
           patient_error: nil,
           patient_name: nil,
           patient_email: nil,
           patient_user: nil,
           past_invite: nil,
           charge_amount: nil,
           amount_error: nil,
           pay_status: nil,
           pay_error: nil,
           page_title: "Create a new charge for a patient | Mindful Care"
         )}

      _ ->
        {:ok,
         assign(socket,
           drchrono_redirect_url: drchrono_redirect_url(socket.assigns.current_user),
           auth_error: nil,
           patient_error: nil,
           patient_name: nil,
           patient_email: nil,
           patient_user: nil,
           past_invite: nil,
           charge_amount: nil,
           amount_error: nil,
           pay_status: nil,
           pay_error: nil,
           page_title: "Create a new charge for a patient | Mindful Care"
         )}
    end
  end

  def handle_event("fetch_patient", %{"email" => email}, socket) do
    case DrchronoAdapter.find_patient_by_email(email) do
      :not_found ->
        {:noreply,
         assign(socket, patient_email: email, patient_error: :not_found, patient_name: nil)}

      {name, drchrono_id} when is_binary(name) ->
        user =
          if u = Accounts.get_user_by_email(email), do: Accounts.save_drchrono_id(u, drchrono_id)

        invite = Mindful.Prospects.get_latest_invite(email)

        {:noreply,
         assign(socket,
           patient_email: email,
           patient_name: name,
           patient_user: user,
           patient_error: nil,
           past_invite: invite
         )}
    end
  end

  def handle_event("send_join_invite_email", _, socket) do
    Mindful.Prospects.create_invite(%{
      to: socket.assigns.patient_email,
      created_by: socket.assigns.current_user.email,
      reason: "join_and_pay"
    })

    Mindful.Accounts.UserNotifier.deliver_join_and_pay_info(
      socket.assigns.patient_email,
      Routes.user_registration_url(socket, :new)
    )

    {:noreply,
     socket
     |> put_flash(:info, "Invite sent to #{socket.assigns.patient_email}")
     |> push_redirect(to: Routes.admin_billing_new_charge_path(socket, :new_charge))}
  end

  def handle_event("send_pay_invite_email", _, socket) do
    Mindful.Prospects.create_invite(%{
      to: socket.assigns.patient_email,
      created_by: socket.assigns.current_user.email,
      reason: "pay"
    })

    Mindful.Accounts.UserNotifier.deliver_pay_info(
      socket.assigns.patient_email,
      Routes.user_url(socket, :billing)
    )

    {:noreply,
     socket
     |> put_flash(:info, "You invited #{socket.assigns.patient_email} to connect a card")
     |> push_redirect(to: Routes.admin_billing_new_charge_path(socket, :new_charge))}
  end

  def handle_event("submit_charge_amount", %{"charge_amount" => charge_amount}, socket) do
    case Float.parse(charge_amount) do
      {float, _} ->
        if float > 0.0 and float < 600.0 do
          {:noreply, assign(socket, charge_amount: float, amount_error: nil)}
        else
          {:noreply, assign(socket, amount_error: :invalid_amount)}
        end

      :error ->
        {:noreply, assign(socket, amount_error: :invalid_amount)}
    end
  end

  def handle_event("charge_patient", _, socket) do
    case Accounts.charge_patient(socket.assigns.patient_user, socket.assigns.charge_amount) do
      {:ok, _} ->
        {:noreply, assign(socket, pay_status: :success)}

      {:error, error} ->
        {:noreply, assign(socket, pay_error: error)}
    end
  end

  defp drchrono_redirect_url(user) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()

    if is_nil(token) and user.email == "mcadenhead@mindful.care" do
      redirect_uri = Application.get_env(:mindful, :general)[:host_url] <> "/admin/new-charge"
      client_id = Application.get_env(:mindful, :drchrono)[:client_id]

      "https://drchrono.com/o/authorize/?redirect_uri=#{redirect_uri}&response_type=code&client_id=#{client_id}"
    end
  end
end
