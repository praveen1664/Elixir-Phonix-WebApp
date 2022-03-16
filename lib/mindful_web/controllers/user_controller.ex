defmodule MindfulWeb.UserController do
  use MindfulWeb, :controller
  alias Mindful.{Accounts, Pverify}
  alias Mindful.Accounts.User
  alias MindfulWeb.PverifyAdapter
  alias MindfulWeb.Services.TokensCache

  def please_confirm(conn, _) do
    render(conn, "please_confirm.html", page_title: "Please Confirm Your Email | Mindful Care")
  end

  def dash(conn, _) do
    changeset = Accounts.change_user_profile(conn.assigns.current_user)
    render(conn, "dash.html", page_title: "My profile | Mindful Care", changeset: changeset)
  end

  def pick_state(conn, _) do
    changeset =
      if conn.assigns.current_user, do: Accounts.change_user_state(conn.assigns.current_user)

    render(conn, "pick_state.html",
      page_title: "Pick Your State | Mindful Care",
      changeset: changeset
    )
  end

  def billing(conn, _) do
    user = Accounts.ensure_stripe_customer!(conn.assigns.current_user)
    client_secret = Accounts.create_stripe_client_secret!(user)
    public_key = Accounts.stripe_public_key_for_state(user.stripe_state)

    render(conn, "billing.html",
      page_title: "Billing | Mindful Care",
      current_user: user,
      client_secret: client_secret,
      public_key: public_key
    )
  end

  def add_card(conn, %{"paymentMethodId" => payment_method_id}) do
    Accounts.set_user_payment_method!(conn.assigns.current_user, payment_method_id)

    conn
    |> put_flash(:success, "Your payment method was added successfully!")
    |> redirect(to: Routes.user_path(conn, :billing))
  end

  def remove_card(conn, _params) do
    Accounts.remove_user_payment_method!(conn.assigns.current_user)

    conn
    |> put_flash(:info, "Payment source removed.")
    |> redirect(to: Routes.user_path(conn, :billing))
  end

  def update_profile(conn, %{"user" => params}) do
    params = add_image_path(params)

    case Accounts.update_user_profile(conn.assigns.current_user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:success, "Your profile has been updated.")
        |> redirect(to: Routes.user_path(conn, :dash))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "dash.html", changeset: changeset)
    end
  end

  def remove_profile_pic(conn, _params) do
    case Accounts.update_user_profile(conn.assigns.current_user, %{image_path: nil}) do
      {:ok, _user} ->
        Accounts.delete_image_from_s3(conn.assigns.current_user.image_path)

        conn
        |> put_flash(:info, "Your profile picture has been removed.")
        |> redirect(to: Routes.user_path(conn, :dash))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "dash.html", changeset: changeset)
    end
  end

  def update_state(conn, %{"state_abbr" => state_abbr}) do
    if conn.assigns.current_user do
      case Accounts.update_user_state(conn.assigns.current_user, %{
             state_abbr: String.downcase(state_abbr)
           }) do
        {:ok, _user} ->
          conn
          |> put_flash(:success, "Great! We've saved your state.")
          |> redirect(to: Routes.user_path(conn, :dash))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "pick_state.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "Use the form to register a new account.")
      |> redirect(to: Routes.user_registration_path(conn, :new, state_abbr))
    end
  end

  def insurance(conn, _params) do
    user = Accounts.get_user!(conn.assigns.current_user.id)
    pverify_data_changeset = Pverify.change_user_pverify_data(user)

    render(conn, "insurance.html",
      page_title: "Insurance | Mindful Care",
      current_user: user,
      user_pverify_data: Pverify.get_user_pverify_data(user),
      payer_codes: Pverify.payer_code_names(user.state.abbr),
      pverify_data_changeset: pverify_data_changeset
    )
  end

  def update_insurance_details(conn, params) do
    user = Accounts.get_user!(conn.assigns.current_user.id)
    params = params |> add_insurance_card_front_path() |> add_insurance_card_back_path()

    with token <- TokensCache.fetch_pverify_token(),
         {:ok, _result} <- Pverify.upsert_insurance_details(user, params["user_pverify_data"]),
         true <- supported_payer?(params),
         %User{} = user <- Accounts.get_user!(user.id),
         {:ok, _result} <- PverifyAdapter.verify_eligibility(user, token) do
      # TODO: Determine logic to calculate amouunt
      amount = 0
      data = Pverify.get_user_pverify_data(user)

      Mindful.Accounts.UserNotifier.deliver_deductible_notification(user, data, amount)

      conn
      |> put_flash(:success, "Great! We've verified your eligibility")
      |> redirect(to: Routes.user_path(conn, :insurance))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "insurance.html",
          current_user: user,
          user_pverify_data: Pverify.get_user_pverify_data(user),
          payer_codes: Pverify.payer_code_names(user.state.abbr),
          pverify_data_changeset: changeset
        )

      {:error, :invalid_payer} ->
        conn
        |> put_flash(:error, "Payer is invalid")
        |> redirect(to: Routes.user_path(conn, :insurance))

      {:error, :invalid_subscriber_id} ->
        conn
        |> put_flash(:error, "Subscriber ID is invalid")
        |> redirect(to: Routes.user_path(conn, :insurance))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Unauthorized request")
        |> redirect(to: Routes.user_path(conn, :insurance))

      false ->
        conn
        |> put_flash(:info, "Verification details submitted")
        |> redirect(to: Routes.user_path(conn, :insurance))

      _err ->
        conn
        |> put_flash(:error, "Self-verification failed")
        |> redirect(to: Routes.user_path(conn, :insurance))
    end
  end

  defp supported_payer?(%{"user_pverify_data" => %{"payer_code" => "Other Payers"}}), do: false
  defp supported_payer?(_params), do: true

  defp add_image_path(params) do
    upload = params["user_image"]
    random_slug = for _ <- 1..20, into: "", do: <<Enum.random('0123456789abcdef')>>
    image_path = upload_image(upload, random_slug) || params["image_path"]
    Map.put(params, "image_path", image_path)
  end

  # TODO: Refactor these functions
  defp add_insurance_card_front_path(params) do
    upload = params |> get_in(["user_pverify_data", "insurance_card_front"])

    if upload do
      random_slug = for _ <- 1..20, into: "", do: <<Enum.random('0123456789abcdef')>>
      image_path = upload_image(upload, random_slug)
      params |> put_in(["user_pverify_data", "insurance_card_front"], image_path)
    else
      params
    end
  end

  defp add_insurance_card_back_path(params) do
    upload = params |> get_in(["user_pverify_data", "insurance_card_back"])

    if upload do
      random_slug = for _ <- 1..20, into: "", do: <<Enum.random('0123456789abcdef')>>
      image_path = upload_image(upload, random_slug)
      params |> put_in(["user_pverify_data", "insurance_card_back"], image_path)
    else
      params
    end
  end

  defp upload_image(%Plug.Upload{} = upload, name) do
    if upload.content_type in Utils.supported_image_formats() do
      file_extension = Path.extname(upload.filename)
      name = name |> String.downcase() |> String.replace(" ", "")
      filename = "/images/users/#{name}#{file_extension}"
      bucket = Application.get_env(:mindful, :bucket)[:name]
      opts = [content_type: upload.content_type, acl: :public_read]

      pic = upload.path |> Mogrify.open() |> Mogrify.save()
      {:ok, file_binary} = File.read(pic.path)

      {:ok, _request} =
        ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()

      {:ok, _request} =
        Utils.create_thumbnail(upload, name, file_extension, bucket, "users", opts, "32x32")

      filename
    end
  end

  defp upload_image(_, _), do: nil
end
