defmodule MindfulWeb.UserRegistrationControllerTest do
  use MindfulWeb.ConnCase, async: true

  import Mindful.Test.Support.UserHelper

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Sign in"
      assert response =~ "Register</button>"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = given_user()
      conn = conn |> log_in_user(user) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/dash"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{email: Faker.Internet.email(), password: Faker.String.base64(20)}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/dash"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Mental healthcare"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Sign up to Mindful Care"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
