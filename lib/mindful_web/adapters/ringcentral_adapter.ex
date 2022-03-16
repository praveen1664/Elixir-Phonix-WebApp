defmodule MindfulWeb.RingCentralAdapter do
  @moduledoc """
   Adapter to integrate with RingCentral Api
  """

  alias HTTPoison.Response
  require Logger

  @default_headers [
    {"Accept", "application/json"}
  ]

  def generate_token do
    ringcentral =
      :mindful
      |> Application.get_env(:ringcentral)

    client_secret =
      ringcentral
      |> Keyword.get(:secret)

    client_id =
      ringcentral
      |> Keyword.get(:id)

    auth_header =
      "#{client_id}:#{client_secret}"
      |> Base.encode64()

    username =
      ringcentral
      |> Keyword.get(:username)

    extension =
      ringcentral
      |> Keyword.get(:extension)

    password =
      ringcentral
      |> Keyword.get(:password)

    body = [
      {"grant_type", "password"},
      {"username", username},
      {"extension", extension},
      {"password", password}
    ]

    with {:ok, response} <-
           request(
             :post,
             "/restapi/oauth/token",
             {:multipart, body},
             [
               {"Authorization", "Basic #{auth_header}"},
               {"Content-Type", "application/x-www-form-urlencoded;charset=UTF-8"}
             ]
           ),
         {_, resp_body} <- process_response(response) do
      resp_body
    end
  end

  defp request(method, endpoint, body, headers) do
    base_url =
      :mindful
      |> Application.get_env(:ringcentral)
      |> Keyword.get(:base_url)

    url = "#{base_url}#{endpoint}"

    Logger.debug("Calling RingCentral API #{method} #{url} #{inspect(body)}")

    response =
      HTTPoison.request(
        method,
        url,
        body,
        headers ++ @default_headers,
        timeout: 100_000,
        recv_timeout: 100_000
      )

    Logger.debug("Got response from RingCentral #{inspect(response)}")
    response
  end

  defp process_response(%Response{body: body, status_code: status}) when status <= 299 do
    Logger.debug(
      "Got a response from RingCentral, status code: #{status}, body: #{inspect(body)}"
    )

    Jason.decode!(body)
  end

  defp process_response(%Response{status_code: status}) when status == 404 do
    Logger.warn("Got an error response from RingCentral with status code #{status}")
    {:error, %{}}
  end

  defp process_response(error_response) do
    Logger.warn(
      "Got an error response from RingCentral with status code #{error_response.status_code}"
    )

    {:error, "Unkown error"}
  end
end
