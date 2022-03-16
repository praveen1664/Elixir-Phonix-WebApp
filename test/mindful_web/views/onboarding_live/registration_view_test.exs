defmodule MindfulWeb.OnboardingLive.RegistrationViewTest do
  use MindfulWeb.ConnCase, async: true

  alias MindfulWeb.OnboardingLive.RegistrationView

  describe "form_title/1" do
    test "must return correct message for invalid step" do
      assert RegistrationView.form_title("invalid") == "Not implemented yet!"
    end

    test "must return correct message for step 1" do
      assert RegistrationView.form_title(1) == "When do you like to see someone?"
    end

    test "must return correct message for step 2" do
      assert RegistrationView.form_title(2) == "Which state do you live in?"
    end

    test "must return correct message for step 3" do
      assert RegistrationView.form_title(3) == "What is the reason for your visit?"
    end

    test "must return correct message for step 4" do
      assert RegistrationView.form_title(4) == "What is your contact info?"
    end
  end

  describe "mark_treatment_as_checked?/2" do
    test "must return false if treatments arg is not a list" do
      refute RegistrationView.mark_treatment_as_checked?(1, "ok")
    end

    test "must return false if treatment is not in treatments list" do
      refute RegistrationView.mark_treatment_as_checked?(["option_1", "option_2"], "option_3")
    end

    test "must return true if treatment is in treatments list" do
      assert RegistrationView.mark_treatment_as_checked?(["option_1", "option_2"], "option_1")
    end
  end

  describe "humanize_field/1" do
    test "must return capitalized string given an :atom" do
      assert "Name" == RegistrationView.humanize_field(:name)

      assert "First name" == RegistrationView.humanize_field(:first_name)
    end
  end

  describe "disable_treatment_checkbox?/2" do
    test "must disable when given treatment is not in available treatments list" do
      assert RegistrationView.disable_treatment_checkbox?("one", ["two", "three"])
      assert RegistrationView.disable_treatment_checkbox?("one", [])
      assert RegistrationView.disable_treatment_checkbox?("", ["two", "three"])
      assert RegistrationView.disable_treatment_checkbox?("", [])
    end

    test "must not disable when given treatment is in available treatments list" do
      refute RegistrationView.disable_treatment_checkbox?("one", ["one", "two", "three"])
    end
  end
end
