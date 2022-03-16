defmodule MindfulWeb.API.HelpScoutController do
  @moduledoc """
  Listens for post requests from Help Scout.
  """

  use MindfulWeb, :controller
  alias MindfulWeb.HelpScoutAdapter, as: HelpScout
  require Logger

  def index(conn, params) do
    with {:ok, phone} <- extract_phone_from_subject(params),
         %{"id" => customer_id} <- HelpScout.get_customer_by_phone(phone) do
      log_phone_extraction_status("succeeded", params)
      base_uri = params["_links"]["self"]["href"]
      HelpScout.reassign_conversation(base_uri, customer_id)
    else
      _ ->
        log_phone_extraction_status("Failed", params)
    end

    json(conn, %{status: :ok})
  end

  def extract_phone_from_subject(%{"subject" => subject}) do
    subject
    |> String.split(" ")
    |> Enum.reject(&Regex.match?(~r/^[[:alpha:]]+$/u, &1))
    |> Enum.take(2)
    |> format_phone()
  end

  # TODO: move to a helper/view, this should not leave in a controller level.
  defp format_phone([phone_prefix, phone_number]) do
    {:ok, phone_prefix <> phone_number}
  end

  defp format_phone(_) do
    nil
  end

  defp log_phone_extraction_status(status, %{"subject" => subject}) do
    # TODO: REMOVE ASAP
    Logger.error("Phone extraction : #{status}: on: #{inspect(subject)}")
  end
end
