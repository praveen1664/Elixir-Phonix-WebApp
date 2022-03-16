defmodule MindfulWeb.Plugs.VerifyStripeWebhook do
  @moduledoc """
  Verifies webhooks are signed by Stripe.
  """
  @behaviour Plug

  require Logger

  import Plug.Conn
  alias MindfulWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(%{request_path: request_path} = conn, _opts) do
    webhook_paths = [
      Routes.stripe_path(conn, :index, "il"),
      Routes.stripe_path(conn, :index, "ny"),
      Routes.stripe_path(conn, :index, "nj")
    ]

    if request_path in webhook_paths, do: verify_req(conn), else: conn
  end

  defp verify_req(conn) do
    case read_body(conn) do
      {:ok, body, conn} -> do_verify(conn, body)
      {:more, _, conn} -> {:error, :too_large, conn}
    end
  end

  defp do_verify(conn, body) do
    [signature] = get_req_header(conn, "stripe-signature")

    secret =
      case conn.request_path do
        "/webhooks/stripe/il" -> Application.get_env(:mindful, :stripe_il)[:wh_secret]
        "/webhooks/stripe/ny" -> Application.get_env(:mindful, :stripe_ny)[:wh_secret]
        "/webhooks/stripe/nj" -> Application.get_env(:mindful, :stripe_nj)[:wh_secret]
      end

    case Stripe.Webhook.construct_event(body, signature, secret) do
      {:ok, %Stripe.Event{} = event} ->
        conn |> assign(:event, event)

      {:error, err} ->
        Logger.error("error verifying stripe event reason: #{err}")

        conn
        |> send_resp(:bad_request, "Webhook Not Verified")
        |> halt()
    end
  end
end
