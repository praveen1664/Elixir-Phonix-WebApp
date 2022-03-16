defmodule Mindful.Accounts.UserNotifier do
  @moduledoc """
  Module for handling sending notifications to users.
  """

  alias Mindful.Mailers.{Email, Mailer}

  @doc """
  Deliver user login link.
  """
  def deliver_confirmation_instructions(user, url),
    do: Email.confirmation_instructions(user, url) |> Mailer.deliver_later()

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url),
    do: Email.reset_password_instructions(user, url) |> Mailer.deliver_later()

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url),
    do: Email.update_email_instructions(user, url) |> Mailer.deliver_later()

  @doc """
  Deliver instructions to the given email address to create a new user account and connect a payment method.
  """
  def deliver_join_and_pay_info(email, url),
    do: Email.join_and_pay_info(email, url) |> Mailer.deliver_later()

  @doc """
  Deliver instructions to the given email to connect a payment method.
  """
  def deliver_pay_info(email, url),
    do: Email.pay_info(email, url) |> Mailer.deliver_later()

  @doc """
  Deliver instructions to the given billing admin's email to let them know a user connected their payment method.
  """
  def deliver_card_connected_alert(invite, url),
    do: Email.card_connected_alert(invite, url) |> Mailer.deliver_later()

  @doc """
  Deliver an email thanking the patient for making a payment.
  """
  def deliver_payment_thank_you(user, amount),
    do: Email.payment_thank_you(user, amount) |> Mailer.deliver_later()

  @doc """
  Deliver an email letting a patient know they have been refunded.
  """
  def deliver_refund_processed(user, amount),
    do: Email.refund_processed(user, amount) |> Mailer.deliver_later()

  @doc """
  Delivers an email letting a patient know their deductible amount
  """
  def deliver_deductible_notification(user, data, amount),
    do: Email.deductible_info(user, data, amount) |> Mailer.deliver_later()
end
