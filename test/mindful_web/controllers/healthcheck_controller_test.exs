defmodule MindfulWeb.HealthCheckControllerTest do
  use MindfulWeb.ConnCase
  import MindfulWeb.Router.Helpers

  test "#check" do
    conn = Phoenix.ConnTest.build_conn()

    response =
      conn
      |> get(health_check_path(conn, :check))
      |> json_response(200)

    assert %{"status" => "ok", "date" => _date} = response
  end
end
