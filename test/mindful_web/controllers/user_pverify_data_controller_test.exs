defmodule MindfulWeb.UserPverifyDataControllerTest do
  use MindfulWeb.ConnCase, async: true
  import Ecto.Changeset
  import Mindful.Test.Support.{StateHelper, UserHelper}
  import Mindful.Test.Support.UserPverifyDataHelper

  setup do
    given_state(%{abbr: "ny"})

    {:ok, user} =
      given_user() |> change(superadmin: true, state_abbr: "ny") |> Mindful.Repo.update()

    %{user: user, user_pverify_data: given_user_pverify_data(%{user_id: user.id})}
  end

  describe "GET /user-pverify-data" do
    test "lists all records for admin", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_pverify_data_path(conn, :index))
      assert conn.status == 200

      records = conn.assigns.user_pverify_data |> Map.values() |> List.first()
      assert length(records) == 1
    end
  end

  describe "GET /user-pverify-data/:id/edit" do
    test "retrieves a single record", %{
      conn: conn,
      user: user,
      user_pverify_data: user_pverify_data
    } do
      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_pverify_data_path(conn, :edit, user_pverify_data.id))

      assert conn.status == 200
      assert conn.assigns.user_pverify_data.id == user_pverify_data.id
    end
  end
end
