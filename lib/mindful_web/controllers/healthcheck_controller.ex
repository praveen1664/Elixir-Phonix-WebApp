defmodule MindfulWeb.HealthCheckController do
  use MindfulWeb, :controller

  def check(conn, _) do
    date = Timex.now()

    conn
    |> put_status(200)
    |> json(%{status: "ok", date: date})
  end
end
