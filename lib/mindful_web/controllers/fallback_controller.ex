defmodule MindfulWeb.FallbackController do
  use MindfulWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(MindfulWeb.ErrorView)
    |> render(:"404")
    |> halt()
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(MindfulWeb.ErrorView)
    |> render(:"401")
    |> halt()
  end

  def call(conn, {:error, :rate_limited}) do
    conn
    |> put_status(:too_many_requests)
    |> put_view(MindfulWeb.ErrorView)
    |> render(:"429",
      message: "You have exceeded the max allowed attempts for this hour."
    )
    |> halt()
  end
end
