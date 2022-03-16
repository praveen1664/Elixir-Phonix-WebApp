defmodule MindfulWeb.OfficeControllerTest do
  use MindfulWeb.ConnCase

  import Mindful.Test.Support.{OfficeHelper, StateHelper}
  alias MindfulWeb.Router.Helpers, as: Routes

  describe "GET /locations/:slug/:o_slug" do
    test "with success must return office page with details", %{conn: conn} do
      state = given_state()
      office = given_office(%{state: state})

      conn = get(conn, Routes.office_path(conn, :show, state.slug, office.slug))

      assert html_response(conn, 200) =~ "Psychiatry & Therapy"
      assert conn.assigns[:office].name == office.name
      assert conn.assigns[:state].name == state.name

      assert conn.assigns[:page_description] ==
               "Fort Greene Brooklyn Psychiatry | Mindful Care New York"

      assert conn.assigns[:page_title] ==
               "Psychiatry and Therapy Treatments at Mindful Care Fort Greene NY"
    end

    test "with success but office without suffix psychiatry must redirect", %{conn: conn} do
      state = given_state()
      office = given_office(%{state: state, slug: "another-slug"})

      conn = get(conn, Routes.office_path(conn, :show, state.slug, office.slug))

      assert redirected_to(conn) ==
               Routes.office_path(conn, :show, state, "#{office.slug}-psychiatry")
    end

    test "with invalid state slug render 404", %{conn: conn} do
      state = given_state()
      office = given_office(%{state: state})

      conn = get(conn, Routes.office_path(conn, :show, "invalid", office.slug))

      assert html_response(conn, 404) =~ "Not Found"
    end
  end
end
