defmodule Mindful.AccountsTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.Helpers
  import Mindful.Test.Support.UserHelper

  alias Mindful.Accounts
  alias Mindful.Accounts.{User, UserToken}

  @email Faker.Internet.email()
  @valid_password Faker.String.base64(20)

  @onboarding_registration_valid_attrs %{
    urgency: "ok",
    state_abbr: "NY",
    treatments: ["Medical"],
    first_name: "First name",
    last_name: "Last name",
    dob: dob(),
    phone: "+1(234) 567-8910",
    email: "my@email.com",
    password: "123qwe123qwe",
    password_confirmation: "123qwe123qwe",
    terms_consent: true,
    treatments_consent: true
  }

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      user = given_user()
      assert Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = given_user()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      user = given_user()
      assert Accounts.get_user_by_email_and_password(user.email, user.password)
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      user = given_user()
      assert Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      user = given_user()
      {:error, changeset} = Accounts.register_user(%{email: user.email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(user.email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      {:ok, user} = Accounts.register_user(%{email: @email, password: @valid_password})
      assert user.email == @email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_registration(
          %User{},
          %{email: @email, password: @valid_password}
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == @email
      assert get_change(changeset, :password) == @valid_password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: given_user()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, user.password, %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, user.password, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.apply_user_email(user, user.password, %{email: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      other_user = given_user()

      {:error, changeset} =
        Accounts.apply_user_email(other_user, user.password, %{email: user.email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, "invalid", %{email: @email})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      {:ok, user} = Accounts.apply_user_email(user, user.password, %{email: @email})
      assert user.email == @email
      assert Accounts.get_user!(user.id).email != @email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{user: given_user()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = given_user(%{confirmed_at: ~N[2022-01-01 06:00:00]})

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: @email}, user.email, url)
        end)

      %{user: user, token: token, email: @email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert :ok == Accounts.update_user_email(user, token)

      changed_user = Repo.get!(User, user.id)

      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at

      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => @valid_password
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == @valid_password
      refute get_change(changeset, :hashed_password)
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: given_user()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, user.password, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, user.password, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: user.password})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password" do
      original_password = Faker.String.base64(20)

      {:ok, user} = %{email: @email, password: original_password} |> Accounts.register_user()

      {:ok, user} =
        Accounts.update_user_password(user, original_password, %{
          password: @valid_password
        })

      refute user.password
      assert Accounts.get_user_by_email_and_password(user.email, @valid_password)
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, user.password, %{
          password: @valid_password
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: given_user()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      other_user = given_user()

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: other_user.id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = given_user()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = given_user()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    test "fails if user is already confirmed" do
      user = given_user()

      assert {:error, :already_confirmed} =
               Accounts.deliver_user_confirmation_instructions(user, fn url -> url end)
    end

    test "sends token through notification" do
      user = given_unconfirmed_user()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = given_unconfirmed_user()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: given_user()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = given_user()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: given_user()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password" do
      original_password = Faker.String.base64(20)
      {:ok, user} = %{email: @email, password: original_password} |> Accounts.register_user()

      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: @valid_password})
      refute updated_user.password
      assert Accounts.get_user_by_email_and_password(user.email, @valid_password)
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: @valid_password})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "new_onboarding_registration_user/2" do
    test "must return a new valid and blank user changeset" do
      attrs = %{
        urgency: "ok",
        state_abbr: "NY",
        treatments: ["Medical"],
        first_name: "First name",
        last_name: "Last name",
        dob: dob(),
        phone: "+1(234) 567-8910",
        email: "my@email.com",
        password: "123qwe123qwe",
        password_confirmation: "123qwe123qwe",
        terms_consent: true,
        treatments_consent: true
      }

      assert %{valid?: true} =
               %Ecto.Changeset{} = Accounts.new_onboarding_registration_user(%User{}, attrs)
    end
  end

  describe "save_onboarding_registration_user/2" do
    test "must register user into the db" do
      total_users_before_new_registration = Mindful.Repo.one(from u in User, select: count(u.id))

      {:ok, _user} =
        Accounts.save_onboarding_registration_user(@onboarding_registration_valid_attrs)

      total_users_after_new_registration = Mindful.Repo.one(from u in User, select: count(u.id))

      assert total_users_after_new_registration > total_users_before_new_registration
      assert total_users_after_new_registration - total_users_before_new_registration == 1
    end

    test "must registers users with a hashed password" do
      {:ok, user} =
        Accounts.save_onboarding_registration_user(@onboarding_registration_valid_attrs)

      assert user.email == @onboarding_registration_valid_attrs[:email]
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end

    test "must return error when data is invalid" do
      {:error, changeset} =
        Accounts.save_onboarding_registration_user(
          Map.drop(@onboarding_registration_valid_attrs, [:phone])
        )

      assert "can't be blank" in errors_on(changeset).phone
    end
  end
end
