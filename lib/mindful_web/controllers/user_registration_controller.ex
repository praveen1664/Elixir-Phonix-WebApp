defmodule MindfulWeb.UserRegistrationController do
  use MindfulWeb, :controller

  alias Mindful.Accounts
  alias Mindful.Accounts.User
  alias MindfulWeb.UserAuth

  def new(conn, %{"state_abbr" => state_abbr}) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset, state_abbr: state_abbr)
  end

  def new(conn, _params) do
    state_abbr = fetch_state_from_ip(conn)
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset, state_abbr: state_abbr)
  end

  def new_w_state(conn, %{"state_abbr" => state_abbr}) do
    redirect(conn, to: Routes.user_registration_path(conn, :new, state_abbr))
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(
          :info,
          "Thanks for joining! Please check your email for a message from us with a link to confirm your email address."
        )
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        state_abbr = user_params["state_abbr"] || fetch_state_from_ip(conn)
        render(conn, "new.html", changeset: changeset, state_abbr: state_abbr)
    end
  end

  defp fetch_state_from_ip(conn) do
    # use IPINFO service to geolocate IP and figure out the state the user lives in
    if conn.remote_ip do
      ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      token = Application.get_env(:mindful, :ipinfo)[:token]
      url = "ipinfo.io/#{ip}?token=#{token}"

      {:ok, %{body: resp}} = HTTPoison.get(url, [{"Content-Type", "application/json"}])

      case Jason.decode(resp) do
        {:ok, %{"region" => state}} ->
          case state do
            "Illinois" -> "il"
            "New Jersey" -> "nj"
            _ -> "ny"
          end

        _ ->
          "ny"
      end
    else
      "ny"
    end
  end
end
