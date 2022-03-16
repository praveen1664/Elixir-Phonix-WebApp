defmodule MindfulWeb.UserSessionController do
  use MindfulWeb, :controller

  alias Mindful.Accounts
  alias MindfulWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html",
      error_message: nil,
      page_title: "Sign in | Mindful Care",
      page_description: "Sign in to your Mindful Care account"
    )
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
