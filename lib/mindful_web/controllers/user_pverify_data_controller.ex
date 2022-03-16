defmodule MindfulWeb.UserPverifyDataController do
  use MindfulWeb, :controller
  alias Mindful.{Accounts, Pverify}
  alias MindfulWeb.PverifyAdapter
  alias MindfulWeb.Services.TokensCache

  def index(conn, _params) do
    render(conn, "index.html",
      page_title: "User Pverify Data | Mindful Care",
      user_pverify_data: Pverify.list_user_pverify_data(false)
    )
  end

  def edit(conn, params) do
    user_pverify_data = params["id"] |> Pverify.get_user_pverify_data_by_id()
    user = Accounts.get_user!(user_pverify_data.user_id)
    pverify_data_changeset = Pverify.change_user_pverify_data(user)

    render(conn, "edit.html",
      page_title: "User Pverify Data | Mindful Care",
      user_pverify_data: user_pverify_data,
      pverify_data_changeset: pverify_data_changeset,
      payer_codes: Pverify.payer_code_names(user.state.abbr),
      user: user
    )
  end

  def update(conn, %{"user_pverify_data" => data} = params) do
    user_pverify_data = params["id"] |> Pverify.get_user_pverify_data_by_id()
    user = Accounts.get_user!(user_pverify_data.user_id)
    token = TokensCache.fetch_pverify_token()

    with {:ok, _result} <- Pverify.upsert_insurance_details(user, data),
         {:ok, _result} <- PverifyAdapter.verify_eligibility(user, token) do
      conn
      |> put_flash(:success, "Patient has been successfully verified")
      |> redirect(to: Routes.user_pverify_data_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          user_pverify_data: Pverify.get_user_pverify_data(user),
          pverify_data_changeset: changeset,
          payer_codes: Pverify.payer_code_names(user.state.abbr),
          user: user
        )

      {:error, :invalid_payer} ->
        conn
        |> put_flash(:error, "Payer is invalid")
        |> redirect(to: Routes.user_pverify_data_path(conn, :edit, params["id"]))

      {:error, :invalid_subscriber_id} ->
        conn
        |> put_flash(:error, "Subscriber ID is invalid")
        |> redirect(to: Routes.user_pverify_data_path(conn, :edit, params["id"]))

      _err ->
        conn
        |> put_flash(:error, "Failed to verify patient's eligibility")
        |> redirect(to: Routes.user_pverify_data_path(conn, :edit, params["id"]))
    end
  end
end
