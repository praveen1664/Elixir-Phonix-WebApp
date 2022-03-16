defmodule MindfulWeb.LiveHelpers do
  @moduledoc """
  MindfulWeb.LiveHelpers module
  """

  @doc """
  Assigns defaults for the socket like current_user.
  """
  def assign_defaults(session_tokens, socket) do
    {:ok,
     socket
     |> assign_current_user(session_tokens["user_token"])
     |> Phoenix.LiveView.assign(:remote_ip, session_tokens["remote_ip"])}
  end

  def assign_current_user(socket, nil), do: Phoenix.LiveView.assign(socket, :current_user, nil)

  def assign_current_user(socket, user_token) do
    Phoenix.LiveView.assign_new(socket, :current_user, fn ->
      Mindful.Accounts.get_user_by_session_token(user_token)
    end)
  end
end
