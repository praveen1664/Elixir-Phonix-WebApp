defmodule Mindful.Accounts.User do
  @moduledoc """
  The User schema
  """
  use Mindful, :schema

  alias Mindful.Appointments.Appointment
  alias Mindful.Locations.State

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime
    field :first_name, :string
    field :last_name, :string
    field :dob, :date
    field :superadmin, :boolean, default: false
    field :roles, {:array, :string}, default: []
    field :stripe_id, :string
    field :stripe_state, :string
    field :payment_method_id, :string
    field :cc_last_4, :string
    field :image_path, :string
    field :phone, :string
    field :about, :string
    field :drchrono_oauth_token, :string
    field :drchrono_oauth_refresh_token, :string
    field :drchrono_oauth_expires_at, :naive_datetime
    field :drchrono_id, :integer
    field :pverify_eligibility_verified, :boolean, default: false

    field :urgency, :string, virtual: true
    field :treatments, {:array, :string}, virtual: true
    field :terms_consent, :boolean, virtual: true
    field :treatments_consent, :boolean, virtual: true
    field :password_confirmation, :string, virtual: true

    belongs_to :state, State, foreign_key: :state_abbr, references: :abbr, type: :string
    has_one :user_pverify_data, Mindful.Pverify.UserPverifyData
    has_many(:appointments, Appointment)

    timestamps()
  end

  @doc """
  A blank user changeset for registration into onboarding flow.

  To build the multi-step form we need a changeset just to build the under the hood form but the validations
  must only be taken at the last step when the user really wanna finish the form and we store the data.any()

  So to allow the form to be build correctly we need a blank changeset for the user, with no validations when it is initialized.
  """
  @onboarding_registration_attrs ~w(
    urgency state_abbr treatments first_name last_name
    phone dob email terms_consent password password_confirmation treatments_consent
  )a
  def onboarding_registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @onboarding_registration_attrs)
    |> validate_required(@onboarding_registration_attrs)
    |> remove_blank_treatments()
    |> remove_invalid_chars_phone()
    |> validate_format(:phone, ~r/^\d+$/, message: "should contain only numbers")
    |> validate_length(:phone, min: 10, message: "should be at least 10 numerical character(s)")
    |> validate_length(:phone, max: 11, message: "should be at most 11 numerical character(s)")
    |> validate_length(:treatments, min: 1)
    |> validate_email()
    |> validate_password(opts)
    |> validate_confirmation(:password)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :state_abbr, :dob])
    |> validate_email()
    |> validate_password(opts)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Mindful.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Mindful.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc """
  A user changeset for changing profile information.
  """
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :about, :image_path, :dob])
    |> validate_length(:first_name, max: 30)
    |> validate_length(:last_name, max: 40)
    |> validate_length(:about, max: 500)
  end

  def state_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:state_abbr])
    |> validate_required([:state_abbr])
  end

  def drchrono_auth_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :drchrono_oauth_token,
      :drchrono_oauth_refresh_token,
      :drchrono_oauth_expires_at
    ])
  end

  def drchrono_changeset(user, attrs), do: user |> cast(attrs, [:drchrono_id])

  def pverify_changeset(user, attrs), do: user |> cast(attrs, [:pverify_eligibility_verified])

  defp remove_blank_treatments(%{changes: %{treatments: treatments}} = changeset)
       when is_list(treatments) and treatments != [] do
    valid_treatments = Enum.reject(treatments, fn treatment -> String.trim(treatment) == "" end)

    put_change(changeset, :treatments, valid_treatments)
  end

  defp remove_blank_treatments(changeset), do: changeset

  defp remove_invalid_chars_phone(%{changes: %{phone: phone}} = changeset) do
    regex_invalid_chars = ~r/[\+\-\(\)\s\@]/

    phone = String.replace(phone, regex_invalid_chars, "") |> String.replace(" ", "")

    put_change(changeset, :phone, phone)
  end

  defp remove_invalid_chars_phone(changeset), do: changeset
end
