defmodule Mindful.Mailers.Email do
  @moduledoc """
  Mindful.Mailers.Email module
  """

  use Bamboo.Phoenix, view: MindfulWeb.EmailView

  @sender_name "Mindful Care"
  @billing "billing@mindful.care"

  def confirmation_instructions(user, url) do
    user
    |> base_email()
    |> from({@sender_name, "confirm@mindful.care"})
    |> subject("Please confirm your email")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:confirmation_instructions)
  end

  def reset_password_instructions(user, url) do
    user
    |> base_email()
    |> from({@sender_name, "resetpassword@mindful.care"})
    |> subject("Reset password")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:reset_password_instructions)
  end

  def update_email_instructions(user, url) do
    user
    |> base_email()
    |> from({@sender_name, "updateemail@mindful.care"})
    |> subject("Update email")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:update_email_instructions)
  end

  def join_and_pay_info(email, url) do
    new_email()
    |> to(email)
    |> put_layout({MindfulWeb.LayoutView, :email})
    |> from({@sender_name, "support@mindful.care"})
    |> subject("Sign up to mindful.care")
    |> assign(:email, email)
    |> assign(:url, url)
    |> render(:join_and_pay_info)
  end

  def pay_info(email, url) do
    new_email()
    |> to(email)
    |> put_layout({MindfulWeb.LayoutView, :email})
    |> from({@sender_name, "support@mindful.care"})
    |> subject("Connect a payment method to your account")
    |> assign(:email, email)
    |> assign(:url, url)
    |> render(:pay_info)
  end

  # This is a notification for the billing team
  # todo: turn this into an in-app notification
  def card_connected_alert(invite, url) do
    new_email()
    |> to(invite.created_by)
    |> cc(@billing)
    |> put_layout({MindfulWeb.LayoutView, :email})
    |> from({@sender_name, "adminalerts@mindful.care"})
    |> subject("A patient has connected their payment method")
    |> assign(:invite, invite)
    |> assign(:url, url)
    |> render(:card_connected_alert)
  end

  def payment_thank_you(user, amount) do
    user
    |> base_email()
    |> from({@sender_name, @billing})
    |> subject("Thank you for your payment to Mindful Care")
    |> assign(:user, user)
    |> assign(:amount, amount)
    |> render(:deliver_payment_thank_you)
  end

  def refund_processed(user, amount) do
    user
    |> base_email()
    |> from({@sender_name, @billing})
    |> subject("Your refund is being processed")
    |> assign(:user, user)
    |> assign(:amount, amount)
    |> render(:deliver_refund_processed)
  end

  @spec deductible_info(User.t(), UserPverifyData.t(), number()) :: Email.t()
  def deductible_info(user, data, amount) do
    user
    |> base_email()
    |> from({@sender_name, @billing})
    |> subject("Your deductible information")
    |> render(:deliver_deductible_info, user: user, data: data, amount: amount)
  end

  defp base_email(user) do
    new_email()
    |> to(user.email)
    |> put_layout({MindfulWeb.LayoutView, :email})
  end
end
