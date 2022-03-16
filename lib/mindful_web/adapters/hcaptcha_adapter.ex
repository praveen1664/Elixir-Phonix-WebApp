defmodule MindfulWeb.HcaptchaAdapter do
  @moduledoc """
  Adapter for working with the Hcaptcha server-side
  """

  @base_uri "https://hcaptcha.com/siteverify"

  def passed_captcha?(nil), do: false
  def passed_captcha?(""), do: false

  def passed_captcha?(response) when is_binary(response) do
    {:ok, %{"success" => result}} = send_response_to_hcaptcha(response)
    result
  end

  defp send_response_to_hcaptcha(response) do
    response = URI.encode_www_form(response)
    secret = URI.encode_www_form(Application.get_env(:mindful, :hcaptcha)[:secret])
    sitekey = URI.encode_www_form(Application.get_env(:mindful, :hcaptcha)[:sitekey])
    body = "response=#{response}&secret=#{secret}&sitekey=#{sitekey}"

    {:ok, %{body: resp}} =
      HTTPoison.post(
        @base_uri,
        body,
        [{"Content-Type", "application/x-www-form-urlencoded"}]
      )

    Jason.decode(resp)
  end
end
