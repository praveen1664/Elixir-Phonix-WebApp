defmodule MindfulWeb.OnboardingLive.RegistrationTest do
  use MindfulWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mindful.Test.Support.StateHelper

  alias Mindful.Accounts.User
  alias MindfulWeb.OnboardingLive.ErrorHandler
  alias MindfulWeb.OnboardingLive.Registration

  setup do
    given_state(%{
      name: "New Jersey",
      abbr: "nj",
      slug: "new-jersey",
      available_treatments: ["medical_management", "therapy", "substance_use_counseling"]
    })

    given_state(%{
      name: "New York",
      abbr: "ny",
      slug: "new-york",
      available_treatments: ["medical_management", "therapy", "substance_use_counseling"]
    })

    given_state(%{
      name: "Illinois",
      abbr: "il",
      slug: "illinois",
      available_treatments: ["medical_management"]
    })

    %{socket: %Phoenix.LiveView.Socket{}}
  end

  describe "mount/3" do
    test "must return proper page_title and step", %{socket: socket} do
      {:ok, socket} = Registration.mount(nil, nil, socket)

      assert socket.assigns.page_title == "Registration | Mindful Care"
      assert socket.assigns.current_step == 1
      assert socket.assigns.errors == %ErrorHandler{}
      refute socket.assigns.changeset.valid?
    end
  end

  describe "handle_event/3" do
    test "must render proper treatments based on selected state", %{socket: socket} do
      {:ok, socket} = Registration.mount(nil, nil, socket)

      {:noreply, socket} =
        Registration.handle_event("validate", %{"user" => %{"state_abbr" => "nj"}}, socket)

      assert socket.assigns.available_treatments == [
               "medical_management",
               "therapy",
               "substance_use_counseling"
             ]

      {:noreply, socket} =
        Registration.handle_event("validate", %{"user" => %{"state_abbr" => "ny"}}, socket)

      assert socket.assigns.available_treatments == [
               "medical_management",
               "therapy",
               "substance_use_counseling"
             ]

      {:noreply, socket} =
        Registration.handle_event("validate", %{"user" => %{"state_abbr" => "il"}}, socket)

      assert socket.assigns.available_treatments == ["medical_management"]
    end
  end

  test "must render the live view page with form", %{conn: conn} do
    conn = get(conn, "/registration")
    assert html_response(conn, 200) =~ "Registration"

    {:ok, view, _html} = live(conn)

    assert has_element?(view, "[name='form_registration_step_1']")
    assert has_element?(view, "[name='form_title']", "When do you like to see someone?")
  end

  describe "step 1" do
    test "must move from step 1 to step 2 when user pick a valid urgency and click next step",
         %{
           conn: conn
         } do
      {:ok, view, _html} = access_registration_path(conn)

      # Starts in the step 1
      assert has_element?(view, "div#step-1")

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      refute has_element?(view, "div#error-message", "There is an error with your submission")

      # Move to step 2
      assert has_element?(view, "div#step-2")
    end

    test "must render error when user does not select urgency and do not move to step 2", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      # Starts in the step 1
      assert has_element?(view, "div#step-1")

      # Do not select a urgency and click directly into Next step
      click_next_step(view, "form#form_registration_step_1")

      # Raise error and user keeps in the step 1
      assert has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-1")
      refute has_element?(view, "div#step-2")
    end

    test "must show error first time user do not pick urgency but after pick one and move to step 2",
         %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      # Starts in the step 1
      assert has_element?(view, "div#step-1")

      # Do not select a urgency and click directly into Next step
      click_next_step(view, "form#form_registration_step_1")

      # Raise error and user keeps in the step 1
      assert has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-1")
      refute has_element?(view, "div#step-2")

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      refute has_element?(view, "div#error-message", "There is an error with your submission")

      # Move to step 2
      assert has_element?(view, "div#step-2")
    end
  end

  describe "step 2" do
    test "must move from step 2 to step 3 when user pick a valid state and click next step", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      # Starts in the step 1
      assert has_element?(view, "div#step-1")

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      refute has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-3")
    end

    test "must render error when use does not select a state and do not move to step 3", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      assert has_element?(view, "div#step-1")

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      assert has_element?(view, "div#step-2")

      # Do not pick a state click directly into Next step
      click_next_step(view, "form#form_registration_step_2")

      # Raise error and user keeps in the step 2
      assert has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-2")
      refute has_element?(view, "div#step-3")
    end

    test "must show error first time user do not pick a state but after pick one and move to step 3",
         %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Do not pick state and moves to next step directly
      click_next_step(view, "form#form_registration_step_2")

      # Raise error and user keeps in the step 2
      assert has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-2")
      refute has_element?(view, "div#step-3")

      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Move to step 3
      assert has_element?(view, "div#step-3")
    end

    test "must redirect when user select option for other state", %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      select_other_state(view)
      click_next_step(view)

      assert_redirected(view, "/locations")
    end
  end

  describe "step 3" do
    test "must move from step 3 to step 4 when user pick at least one option and click next step",
         %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      assert has_element?(view, "div#step-1")

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Assert is in step 3
      assert has_element?(view, "div#step-3")

      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      refute has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-4")
    end

    test "must show proper treatments based on state selected in step 2",
         %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      assert has_element?(view, "div#step-1")

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view, "il")
      click_next_step(view, "form#form_registration_step_2")

      # Assert is in step 3
      assert has_element?(view, "div#step-3")
      assert has_element?(view, "[for='treatment_medical_management']", "Medical Management")
      assert has_element?(view, "[for='treatment_therapy']", "[Coming soon]")
      assert has_element?(view, "[for='treatment_substance_use_counseling']", "[Coming soon]")
    end

    test "must render error when user does not select any reason and do not move to step 4", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      assert has_element?(view, "div#step-1")

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Assert is in step 3
      assert has_element?(view, "div#step-3")

      # Do not pick a reason click directly into Next step
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#error-message", "There is an error with your submission")
      refute has_element?(view, "div#step-4")
    end

    test "must render error first time when use does not select any reason but after pick one moves to step 4",
         %{
           conn: conn
         } do
      {:ok, view, _html} = access_registration_path(conn)

      assert has_element?(view, "div#step-1")

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Assert is in step 3
      assert has_element?(view, "div#step-3")

      # Do not pick a reason click directly into Next step
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#error-message", "There is an error with your submission")
      refute has_element?(view, "div#step-4")

      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      refute has_element?(view, "div#error-message", "There is an error with your submission")
      assert has_element?(view, "div#step-4")
    end
  end

  describe "step 4" do
    test "must move from step 4 to step 5 when user complete the form and click next step", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      assert [] = Repo.all(User)

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Step 3 done
      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#step-4")

      fill_form_with_valid_data(view)
      click_submit(view)

      [user] = Repo.all(User)

      assert %{
               first_name: "Luiz",
               last_name: "Cezer",
               phone: "1234567891",
               dob: ~D[1990-12-31],
               email: "lfilho@test.com"
             } = user

      assert_redirected(view, "/registration/schedule?user_id=#{user.id}&state=ny")
    end

    test "must render error when user does fill all required fields and do not move to next step",
         %{conn: conn} do
      {:ok, view, _html} = access_registration_path(conn)

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Step 3 done
      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#step-4")

      click_submit(view)

      assert has_element?(view, "div#error-message", "There is an error with your submission")
    end

    test "must render error when user first_name is invalid and do not move to next step", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Step 3 done
      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#step-4")

      fill_first_name_with_invalid_data(view)
      click_submit(view)

      assert has_element?(view, "div#error-message", "There is an error with your submission")

      assert has_element?(
               view,
               "div#error-message",
               "First name: can't be blank"
             )
    end

    test "must render error when user phone is invalid and do not move to next step", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Step 3 done
      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#step-4")

      fill_phone_with_invalid_data(view)
      click_submit(view)

      assert has_element?(view, "div#error-message", "There is an error with your submission")

      assert has_element?(
               view,
               "div#error-message",
               "Phone: should be at least 10 numerical character(s)"
             )
    end

    test "must render error when user email is invalid and do not move to next step", %{
      conn: conn
    } do
      {:ok, view, _html} = access_registration_path(conn)

      # Step 1 done
      select_urgency(view)
      click_next_step(view, "form#form_registration_step_1")

      # Step 2 done
      select_valid_state(view)
      click_next_step(view, "form#form_registration_step_2")

      # Step 3 done
      select_treatments_options(view)
      click_next_step(view, "form#form_registration_step_3")

      assert has_element?(view, "div#step-4")

      fill_email_with_invalid_data(view)
      click_submit(view)

      assert has_element?(view, "div#error-message", "There is an error with your submission")

      assert has_element?(
               view,
               "div#error-message",
               "Email: must have the @ sign and no spaces"
             )
    end
  end

  defp access_registration_path(conn) do
    conn
    |> get("/registration")
    |> live()
  end

  defp select_urgency(view) do
    view
    |> element("#form_registration_step_1")
    |> render_change(%{user: %{urgency: "premium"}})
  end

  defp click_submit(view) do
    view
    |> element("#form_registration_step_4")
    |> render_submit()
  end

  defp click_next_step(view, form_id) do
    view
    |> element(form_id)
    |> render_submit()
  end

  def click_next_step(view) do
    view
    |> element("#next_step")
    |> render_click()
  end

  defp select_valid_state(view, state \\ "NY") do
    view
    |> element("#form_registration_step_2")
    |> render_change(%{user: %{state_abbr: state}})
  end

  defp select_other_state(view) do
    view
    |> element("#form_registration_step_2")
    |> render_change(%{user: %{state_abbr: "other_state"}})
  end

  defp select_treatments_options(view) do
    view
    |> element("#form_registration_step_3")
    |> render_change(%{
      user: %{
        treatments: %{
          "medical_management" => "true",
          "therapy" => "true",
          "substance_use_counseling" => "false"
        }
      }
    })
  end

  defp fill_form_with_valid_data(view) do
    view
    |> element("#form_registration_step_4")
    |> render_change(%{
      user: %{
        first_name: "Luiz",
        last_name: "Cezer",
        phone: "1234567891",
        dob: ~D[1990-12-31],
        email: "lfilho@test.com",
        password: "123qwe123qwe",
        password_confirmation: "123qwe123qwe",
        terms_consent: "true",
        treatments_consent: "true"
      }
    })
  end

  defp fill_first_name_with_invalid_data(view) do
    view
    |> element("#form_registration_step_4")
    |> render_change(%{user: %{first_name: ""}})
  end

  defp fill_phone_with_invalid_data(view) do
    view
    |> element("#form_registration_step_4")
    |> render_change(%{user: %{phone: "123456789"}})
  end

  defp fill_email_with_invalid_data(view) do
    view
    |> element("#form_registration_step_4")
    |> render_change(%{user: %{email: "my @ email.com"}})
  end
end
