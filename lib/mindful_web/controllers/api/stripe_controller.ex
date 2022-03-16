defmodule MindfulWeb.API.StripeController do
  @moduledoc """
  Listens for post requests from Stripe.
  """

  use MindfulWeb, :controller

  alias Mindful.Accounts

  @doc """
  Processes webhook events from Stripe.
  """
  def index(conn, _params) do
    event = conn.assigns.event

    case event.type do
      "payment_intent.succeeded" ->
        %Stripe.Event{data: %{object: %{customer: stripe_id, amount: amount}}} = event
        user = Accounts.get_user_by_stripe_id!(stripe_id)
        # Send thank you for payment email to patient
        Mindful.Accounts.UserNotifier.deliver_payment_thank_you(user, amount)

        send_resp(conn, 200, "ok")

      "charge.refunded" ->
        %Stripe.Event{data: %{object: %{customer: stripe_id, amount: amount}}} = event
        user = Accounts.get_user_by_stripe_id!(stripe_id)
        # Create refund in Dr. Chrono
        MindfulWeb.DrchronoAdapter.reflect_refund(user, amount)
        # Send refund processed email to patient
        Mindful.Accounts.UserNotifier.deliver_refund_processed(user, amount)

        send_resp(conn, 200, "ok")

      _ ->
        send_resp(conn, 400, "Error: unauthorized webhook event.")
    end
  end
end
