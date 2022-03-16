defmodule Mindful.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Ecto.Multi
  alias Mindful.Repo
  alias Mindful.Accounts.{User, UserNotifier, UserToken}

  ## Database getters

  def get_user_by_email(email) do
    User |> preload([:state, :user_pverify_data]) |> Repo.get_by(email: email)
  end

  def get_user_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  def get_user!(id), do: User |> preload([:state, :user_pverify_data]) |> Repo.get!(id)

  def get_user_by_stripe_id!(stripe_id), do: Repo.get_by!(User, stripe_id: stripe_id)

  @doc """
  Registers a user.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.
  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = user |> User.email_changeset(%{email: email}) |> User.confirm_changeset()

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.
  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Multi.new()
    |> Multi.update(:user, User.confirm_changeset(user))
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.
  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.
  """
  def reset_user_password(user, attrs) do
    Multi.new()
    |> Multi.update(:user, User.password_changeset(user, attrs))
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def set_user_payment_method!(user, pm_id) do
    api_key = select_stripe_api_key_for_state(user.stripe_state)

    if user.payment_method_id,
      do: Stripe.PaymentMethod.detach(%{payment_method: user.payment_method_id}, api_key: api_key)

    {:ok, pm} = Stripe.PaymentMethod.retrieve(pm_id, api_key: api_key)

    # delete any past invites and notify billing admin if necessary
    url = MindfulWeb.Router.Helpers.admin_billing_new_charge_url(MindfulWeb.Endpoint, :new_charge)
    Mindful.Prospects.delete_invites_and_notify_billing(user.email, url)

    Repo.update!(
      Ecto.Changeset.change(user, %{payment_method_id: pm_id, cc_last_4: pm.card.last4})
    )
  end

  @doc """
  Create a customer in Stripe to associate with the given user.
  """
  def ensure_stripe_customer!(%User{stripe_id: nil} = user) do
    api_key = select_stripe_api_key_for_state(user.state_abbr)
    {:ok, customer} = Stripe.Customer.create(%{email: user.email}, api_key: api_key)

    Repo.update!(
      Ecto.Changeset.change(user, %{stripe_id: customer.id, stripe_state: user.state_abbr})
    )
  end

  def ensure_stripe_customer!(user), do: user

  defp select_stripe_api_key_for_state("il"),
    do: Application.get_env(:mindful, :stripe_il)[:api_key]

  defp select_stripe_api_key_for_state("nj"),
    do: Application.get_env(:mindful, :stripe_nj)[:api_key]

  defp select_stripe_api_key_for_state(_), do: Application.get_env(:mindful, :stripe_ny)[:api_key]

  def stripe_public_key_for_state("il"),
    do: Application.get_env(:mindful, :stripe_il)[:public_key]

  def stripe_public_key_for_state("nj"),
    do: Application.get_env(:mindful, :stripe_nj)[:public_key]

  def stripe_public_key_for_state(_), do: Application.get_env(:mindful, :stripe_ny)[:public_key]

  @doc """
  Creates a client secret for the given stripe customer id that
  is needed for setting up future payments when adding a card.
  """
  def create_stripe_client_secret!(%User{stripe_id: stripe_id} = user)
      when is_binary(stripe_id) do
    api_key = select_stripe_api_key_for_state(user.stripe_state)

    {:ok, %{client_secret: cs}} =
      Stripe.SetupIntent.create(%{customer: stripe_id}, api_key: api_key)

    cs
  end

  @doc """
  Removes the user's payment method.
  """
  @spec remove_user_payment_method!(User.t()) :: User.t()
  def remove_user_payment_method!(%User{payment_method_id: pm_id} = user) when is_binary(pm_id) do
    api_key = select_stripe_api_key_for_state(user.stripe_state)
    {:ok, _} = Stripe.PaymentMethod.detach(%{payment_method: pm_id}, api_key: api_key)
    Repo.update!(Ecto.Changeset.change(user, %{payment_method_id: nil, cc_last_4: nil}))
  end

  def remove_user_payment_method!(user), do: user

  @doc """
  Saves the access_token, refresh_token, and expiry for the given user's Dr. Chrono account.
  """
  def save_chrono_auth_info!(user, data),
    do: Repo.update!(User.drchrono_auth_changeset(user, data))

  @doc """
  Charges the user's payment method for the given amount.
  """
  def charge_patient(%User{} = user, amount) when is_float(amount) do
    case create_payment_intent(user, amount) do
      {:ok, %Stripe.PaymentIntent{id: pi_id}} ->
        case MindfulWeb.DrchronoAdapter.reflect_charge(user, amount, pi_id) do
          :ok ->
            {:ok, pi_id}

          _error ->
            {:error,
             "Charge succeeded in Stripe but failed to post to Dr. Chrono. Please update Dr. Chrono manually."}
        end

      {:error, %Stripe.Error{message: err_msg}} ->
        {:error, err_msg}
    end
  end

  defp create_payment_intent(user, amount) do
    # Stripe takes a cents amount so multiply by 100
    amount = (amount * 100) |> trunc()
    api_key = select_stripe_api_key_for_state(user.stripe_state)

    Stripe.PaymentIntent.create(
      %{
        payment_method_types: ["card"],
        amount: amount,
        currency: "usd",
        confirm: "true",
        off_session: "true",
        customer: user.stripe_id,
        payment_method: user.payment_method_id
      },
      api_key: api_key
    )
  end

  @doc """
  Saves the Dr. Chrono patient id for the given user if it is not already set.
  """
  def save_drchrono_id(%User{drchrono_id: nil} = user, drchrono_id) do
    Repo.update!(Ecto.Changeset.change(user, %{drchrono_id: drchrono_id}))
  end

  def save_drchrono_id(user, _), do: user

  def change_user_profile(%User{} = user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  @doc """
  Updates the given user's profile information.
  """
  def update_user_profile(%User{} = user, attrs) do
    # delete old profile image if it exists and is being updated
    if user.image_path && is_binary(attrs["image_path"]),
      do: delete_image_from_s3(user.image_path)

    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def update_user_pverify_verification_status(%User{} = user, attrs) do
    user
    |> User.pverify_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the profile image and thumbnail from AWS S3.
  """
  def delete_image_from_s3(path) when is_binary(path) do
    bucket = Application.get_env(:mindful, :bucket)[:name]
    "/" <> path = path
    objects = [path, String.replace(path, ".", "_thumbnail.")]
    # todo: figure out why this isn't deleting the files from S3
    ExAws.S3.delete_multiple_objects(bucket, objects)
  end

  def change_user_state(user), do: User.state_changeset(user)

  def update_user_state(user, params) do
    Repo.update(User.state_changeset(user, params))
  end

  @doc """
  Returns a new changeset for user in onboarding flow
  """
  def new_onboarding_registration_user(%User{} = user, params \\ %{}) do
    User.onboarding_registration_changeset(user, params, hash_password: false)
  end

  @doc """
  Saves a new user from onboarding flow
  """
  def save_onboarding_registration_user(attrs) do
    %User{}
    |> User.onboarding_registration_changeset(attrs)
    |> Repo.insert()
  end
end
