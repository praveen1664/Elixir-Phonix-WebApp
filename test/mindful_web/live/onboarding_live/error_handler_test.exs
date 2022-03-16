defmodule MindfulWeb.OnboardingLive.ErrorHandlerTest do
  use ExUnit.Case
  use MindfulWeb.ConnCase

  alias Mindful.Accounts
  alias Mindful.Accounts.User
  alias MindfulWeb.OnboardingLive.ErrorHandler, as: Handler

  describe "extract/2" do
    test "must return {fase, %ErrorHandler{}} when there is no errors on changeset" do
      assert Handler.extract(:key, %{errors: []}) == {false, %Handler{}}
    end

    test "must return {true, %ErrorHandler{message: 'message'}} when there is an error on changeset" do
      changeset = Accounts.new_onboarding_registration_user(%User{}, %{})

      assert Handler.extract(:urgency, changeset) == {true, %Handler{message: "can't be blank"}}
    end

    test "must return {true, %ErrorHandler{message: 'message', count: 1}} with count when there is an error on changeste" do
      changeset =
        Accounts.new_onboarding_registration_user(%User{}, %{
          treatments: [""],
          urgency: "ok",
          state_abbr: "NY",
          first_name: "First name",
          last_name: "Last name",
          dob: "dob",
          phone: "phone",
          email: "my@email.com",
          terms_consent: true
        })

      assert Handler.extract(:treatments, changeset) ==
               {true, %Handler{message: "should have at least %{count} item(s)", count: "1"}}

      changeset =
        Accounts.new_onboarding_registration_user(%User{}, %{
          treatments: ["medical"],
          urgency: "ok",
          state_abbr: "NY",
          first_name: "First name",
          last_name: "Last name",
          dob: "dob",
          phone: "123456789123",
          email: "my@email.com",
          terms_consent: true
        })

      assert Handler.extract(:phone, changeset) ==
               {true,
                %Handler{message: "should be at most 11 numerical character(s)", count: "11"}}
    end
  end
end
