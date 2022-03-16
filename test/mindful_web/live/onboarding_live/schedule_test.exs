defmodule MindfulWeb.OnboardingLive.ScheduleTest do
  use MindfulWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mindful.Test.Support.OfficeHelper
  import Mindful.Test.Support.ProviderHelper
  import Mindful.Test.Support.UserHelper

  alias MindfulWeb.OnboardingLive.Schedule

  setup do
    office = given_office()
    provider = given_provider(%{office: office})
    user = given_user()
    socket = %Phoenix.LiveView.Socket{}

    {:ok, user: user, provider: provider, office: office, socket: socket}
  end

  describe "mount/3" do
    test "loads offices with providers and sets state", %{
      socket: socket,
      user: user,
      office: office,
      provider: provider
    } do
      params = %{"user_id" => user.id, "state" => "ny"}
      {:ok, socket} = Schedule.mount(params, nil, socket)

      assert socket.assigns.page_title == "Registration - Schedule | Mindful Care"
      assert socket.assigns.step == "select_office"
      assert [off] = socket.assigns.offices
      assert off.id == office.id
      assert [prov] = off.providers
      assert prov.id == provider.id
    end
  end

  test "must render the live view page", %{conn: conn, user: user, office: office} do
    conn = get(conn, "/registration/schedule?user_id=#{user.id}&state=#{office.state_abbr}")

    assert html_response(conn, 200) =~ "Please Select A Preferred Office"
    assert html_response(conn, 200) =~ office.name
  end

  describe "handle_event/3" do
    test "must render offices based on selected state", %{
      socket: socket,
      office: office,
      user: user
    } do
      given_office(%{name: "Grand Central", state: office.state, slug: "grand-central"})

      socket = set_state(socket, user, office)

      assert socket.assigns.step == "select_office"
      assert length(socket.assigns.offices) == 2
    end

    test "selects office", %{socket: socket, office: office, user: user} do
      given_office(%{name: "Grand Central", state: office.state, slug: "grand-central"})

      socket =
        socket
        |> set_state(user, office)
        |> handle_event("select_office", %{"office_id" => office.id})

      assert socket.assigns.step == "select_provider"
      assert socket.assigns.selected_office.id == office.id
    end

    test "selects provider", %{socket: socket, office: office, user: user, provider: provider} do
      given_office(%{name: "Grand Central", state: office.state, slug: "grand-central"})

      socket =
        socket
        |> set_state(user, office)
        |> handle_event("select_office", %{"office_id" => office.id})
        |> handle_event("select_provider", %{"provider_id" => provider.id})

      assert socket.assigns.step == "select_schedule"
      assert socket.assigns.selected_office.id == office.id
      assert socket.assigns.selected_provider.id == provider.id
    end

    test "goes back one step", %{socket: socket, office: office, user: user, provider: provider} do
      given_office(%{name: "Grand Central", state: office.state, slug: "grand-central"})

      socket =
        socket
        |> set_state(user, office)
        |> handle_event("select_office", %{"office_id" => office.id})
        |> handle_event("select_provider", %{"provider_id" => provider.id})
        |> handle_event("back", %{"back" => "select_office"})

      assert socket.assigns.step == "select_office"
    end
  end

  test "must render providers when office is selected", %{
    conn: conn,
    user: user,
    office: office,
    provider: provider
  } do
    {:ok, view, _html} = access_schedule_path(conn, user, office)

    select_office(view, office)

    assert has_element?(view, "div#provider-#{provider.id}")
    assert render(view) =~ "Select A Health Provider"
  end

  test "must render calendar when provider is selected", %{
    conn: conn,
    user: user,
    office: office,
    provider: provider
  } do
    {:ok, view, _html} = access_schedule_path(conn, user, office)

    select_office(view, office)
    select_provider(view, provider)

    assert has_element?(view, "div#calendar-wrapper")
    assert render(view) =~ "Select A Convenient Date &amp; Time"
  end

  # Private Functions

  defp access_schedule_path(conn, user, office) do
    conn
    |> get("/registration/schedule?user_id=#{user.id}&state=#{office.state_abbr}")
    |> live()
  end

  defp set_state(socket, user, office) do
    params = %{"user_id" => user.id, "state" => office.state_abbr}
    {:ok, socket} = Schedule.mount(params, nil, socket)

    socket
  end

  defp handle_event(socket, event, attrs) do
    {:noreply, socket} = Schedule.handle_event(event, attrs, socket)

    socket
  end

  defp select_office(view, office) do
    view
    |> element("#office-#{office.id}")
    |> render_click()
  end

  defp select_provider(view, provider) do
    view
    |> element("#provider-#{provider.id}")
    |> render_click()
  end
end
