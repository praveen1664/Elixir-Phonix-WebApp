defmodule Mindful.Accounts.UserTest do
  use Mindful.DataCase

  alias Mindful.Accounts.User
  alias Mindful.Test.Support.UserHelper

  describe "onboarding_registration_changeset/2" do
    test "must return a valid changeset" do
      %{valid?: true} =
        User.onboarding_registration_changeset(%User{}, %{
          urgency: "ok",
          state_abbr: "NY",
          treatments: ["Medical"],
          first_name: "First name",
          last_name: "Last name",
          dob: UserHelper.dob(),
          phone: "+1(123)123-1234",
          email: "my@email.com",
          password: "123qwe123qwe",
          password_confirmation: "123qwe123qwe",
          terms_consent: true,
          treatments_consent: true
        })
    end

    test "must return an invalid changeset" do
      %{valid?: false} = changeset = User.onboarding_registration_changeset(%User{}, %{})

      assert %{
               urgency: ["can't be blank"],
               state_abbr: ["can't be blank"],
               treatments: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               dob: ["can't be blank"],
               phone: ["can't be blank"],
               email: ["can't be blank"],
               password: ["can't be blank"],
               password_confirmation: ["can't be blank"],
               terms_consent: ["can't be blank"],
               treatments_consent: ["can't be blank"]
             } = errors_on(changeset)
    end

    # Treatments
    test "must return errors when do not pick at least 1 treatment" do
      %{valid?: false} =
        changeset =
        User.onboarding_registration_changeset(%User{}, %{
          urgency: "ok",
          state_abbr: "NY",
          treatments: []
        })

      assert %{treatments: ["should have at least 1 item(s)"]} = errors_on(changeset)

      %{valid?: false} =
        changeset =
        User.onboarding_registration_changeset(%User{}, %{
          urgency: "ok",
          state_abbr: "NY",
          treatments: [""]
        })

      assert %{treatments: ["should have at least 1 item(s)"]} = errors_on(changeset)
    end

    # Phone
    test "must return only numbers from the given phone" do
      %{valid?: false} =
        %{changes: %{phone: phone}} =
        User.onboarding_registration_changeset(%User{}, %{
          phone: "+1 (555) 987-6543"
        })

      assert phone == "15559876543"

      %{valid?: false} =
        %{changes: %{phone: phone}} =
        User.onboarding_registration_changeset(%User{}, %{
          phone: "+1(555)987-6543"
        })

      assert phone == "15559876543"

      %{valid?: false} =
        %{changes: %{phone: phone}} =
        User.onboarding_registration_changeset(%User{}, %{
          phone: "(555)987-6543"
        })

      assert phone == "5559876543"

      %{valid?: false} =
        %{changes: %{phone: phone}} =
        User.onboarding_registration_changeset(%User{}, %{
          phone: "15559876543"
        })

      assert phone == "15559876543"
    end

    # Phone will be clean as a first stage to remove invalid chars,
    # should remain only numbers and at min 10 chars and max 11.
    test "must return error when phone has more than 11 numerical chars" do
      %{valid?: false} =
        changeset = User.onboarding_registration_changeset(%User{}, %{phone: "+1(123)123 12345"})

      assert "should be at most 11 numerical character(s)" in errors_on(changeset).phone
    end

    test "must return error when phone has less than 10 numerical chars" do
      %{valid?: false} =
        changeset = User.onboarding_registration_changeset(%User{}, %{phone: "(3)123 12345"})

      assert "should be at least 10 numerical character(s)" in errors_on(changeset).phone
    end

    test "must raise error when phone contains letters only" do
      %{valid?: false} =
        changeset = User.onboarding_registration_changeset(%User{}, %{phone: "aaaaaaaaaa"})

      assert "should contain only numbers" in errors_on(changeset).phone
    end

    test "must raise error when phone contains letters and numbers" do
      %{valid?: false} =
        changeset = User.onboarding_registration_changeset(%User{}, %{phone: "1111111111a"})

      assert "should contain only numbers" in errors_on(changeset).phone
    end

    # Email
    test "must return error when email has invalid format" do
      %{valid?: false} =
        changeset =
        User.onboarding_registration_changeset(%User{}, %{
          urgency: "ok",
          state_abbr: "NY",
          treatments: ["Medical"],
          first_name: "First name",
          last_name: "Last name",
          dob: "dob",
          phone: "+1(123)123-1234",
          email: "my@",
          terms_consent: true,
          treatments_consent: false
        })

      assert "must have the @ sign and no spaces" in errors_on(changeset).email

      %{valid?: false} =
        changeset =
        User.onboarding_registration_changeset(%User{}, %{
          urgency: "ok",
          state_abbr: "NY",
          treatments: ["Medical"],
          first_name: "First name",
          last_name: "Last name",
          dob: "dob",
          phone: "+1(123)123-1234",
          email: "my@. com",
          terms_consent: true,
          treatments_consent: false
        })

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    # Password confirmation
    test "must return error when password and password_confirmation are diff" do
      %{valid?: false} =
        changeset =
        User.onboarding_registration_changeset(%User{}, %{
          password: "123qwe123qwe",
          password_confirmation: "123qweqwe123"
        })

      assert "does not match confirmation" in errors_on(changeset).password_confirmation
    end
  end
end
