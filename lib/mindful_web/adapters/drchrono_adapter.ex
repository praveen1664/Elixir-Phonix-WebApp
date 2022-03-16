defmodule MindfulWeb.DrchronoAdapter do
  @moduledoc """
  Adapter for working with the Dr. Chrono API.
  """

  alias MindfulWeb.Services.TokensCache

  def exchange_auth_code(code) do
    base_uri = "https://drchrono.com/o/token/"
    redirect_uri = Application.get_env(:mindful, :general)[:host_url] <> "/admin/new-charge"
    client_id = URI.encode_www_form(Application.get_env(:mindful, :drchrono)[:client_id])
    secret = URI.encode_www_form(Application.get_env(:mindful, :drchrono)[:secret])

    body =
      "code=#{code}&grant_type=authorization_code&redirect_uri=#{redirect_uri}&client_id=#{client_id}&client_secret=#{secret}"

    {:ok, %{body: resp}} =
      HTTPoison.post(base_uri, body, [{"Content-Type", "application/x-www-form-urlencoded"}])

    case Jason.decode(resp) do
      {:ok, %{"access_token" => _} = data} ->
        # put access token in a map with the same drchrono fields as the user schema
        %{
          drchrono_oauth_token: data["access_token"],
          drchrono_oauth_refresh_token: data["refresh_token"],
          drchrono_oauth_expires_at: expires_in(data["expires_in"]),
          # add this redundant field to pass a ttl to the tokens cache instead of using the expires at field
          expires_in: data["expires_in"]
        }

      {:ok, %{"error" => error}} ->
        error
    end
  end

  def exchange_refresh_token(refresh_token) do
    base_uri = "https://drchrono.com/o/token/"
    client_id = URI.encode_www_form(Application.get_env(:mindful, :drchrono)[:client_id])
    secret = URI.encode_www_form(Application.get_env(:mindful, :drchrono)[:secret])

    body =
      "grant_type=refresh_token&client_id=#{client_id}&client_secret=#{secret}&refresh_token=#{refresh_token}"

    {:ok, %{body: resp}} =
      HTTPoison.post(base_uri, body, [{"Content-Type", "application/x-www-form-urlencoded"}])

    case Jason.decode(resp) do
      {:ok, %{"access_token" => _} = data} ->
        # put access token in a map with the same drchrono fields as the user schema
        token_data = %{
          drchrono_oauth_token: data["access_token"],
          drchrono_oauth_refresh_token: data["refresh_token"],
          drchrono_oauth_expires_at: expires_in(data["expires_in"])
        }

        {:ok, token_data}

      {:ok, %{"error" => error}} ->
        {:error, error}
    end
  end

  @callback find_patient_by_email(String.t()) :: {:ok, any()} | {:error, any()}
  def find_patient_by_email(email) do
    token = TokensCache.get_drchrono_token()
    base_uri = "https://drchrono.com/api/patients"
    params = "?email=#{email}"

    {:ok, %{body: resp}} =
      HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}])

    case Jason.decode(resp) do
      {:ok, %{"results" => [result]}} ->
        {result["first_name"] <> " " <> result["last_name"], result["id"]}

      {:ok, %{"results" => []}} ->
        :not_found

      error ->
        error
    end
  end

  def fetch_patient(nil), do: nil

  def fetch_patient(drchrono_id) when is_integer(drchrono_id) do
    token = TokensCache.get_drchrono_token()
    uri = "https://drchrono.com/api/patients/" <> to_string(drchrono_id)

    with {:ok, %{body: resp}} <- HTTPoison.get(uri, [{"Authorization", "Bearer #{token}"}]) do
      case Jason.decode(resp) do
        {:ok, %{"id" => _id} = chrono_patient} ->
          chrono_patient

        {:ok, %{"detail" => detail}} ->
          raise "Error when fetching patient with Dr. Chrono ID #{drchrono_id}. Error detail: #{detail}"
      end
    else
      {:error, %HTTPoison.Error{id: _id, reason: :timeout}} ->
        raise "Error: Request timed out"
    end
  end

  @doc """
  Posts a new patient payment to the patient's record on Drchrono.
  """
  def reflect_charge(user, amount, pi_id) do
    token = TokensCache.get_drchrono_token()
    base_uri = "https://drchrono.com/api/patient_payments"

    body =
      Jason.encode!(%{
        patient: user.drchrono_id,
        amount: amount,
        payment_method: "PTPA",
        payment_transaction_type: "",
        notes: "Charged through admin portal. Stripe ID: #{pi_id}"
      })

    {:ok, %{body: resp}} =
      HTTPoison.post(base_uri, body, [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{token}"}
      ])

    case Jason.decode(resp) do
      {:ok, %{"amount" => _amount}} ->
        :ok

      {:ok, %{"error" => error}} ->
        error
    end
  end

  @doc """
  Posts a refund to the patient's record on Drchrono.
  """
  def reflect_refund(user, amount) do
    token = TokensCache.get_drchrono_token()
    base_uri = "https://drchrono.com/api/patient_payments"

    body =
      Jason.encode!(%{
        patient: user.drchrono_id,
        amount: -1 * amount / 100,
        payment_method: "PTPA",
        payment_transaction_type: "REF",
        notes: "Refunded in Stripe dashboard."
      })

    {:ok, %{body: resp}} =
      HTTPoison.post(base_uri, body, [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{token}"}
      ])

    case Jason.decode(resp) do
      {:ok, %{"amount" => _amount}} ->
        :ok

      {:ok, %{"error" => error}} ->
        error
    end
  end

  defp expires_in(seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(seconds, :second)
    |> NaiveDateTime.truncate(:second)
  end

  # def get_no_shows_for_month(user, month, start_day, end_day, cursor \\ nil) do
  #   base_uri = "https://drchrono.com/api/appointments"
  #   cursor_query = if cursor, do: "&cursor=#{URI.encode_www_form(cursor)}", else: ""

  #   params =
  #     "?date_range=2021-#{month}-#{start_day}%2f2021-#{month}-#{end_day}&status=No%20Show&page_size=20" <>
  #       cursor_query

  #   {:ok, %{body: resp}} =
  #     HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{user.drchrono_oauth_token}"}])

  #   case Jason.decode(resp) do
  #     {:ok, %{"next" => next, "results" => results}} ->
  #       update_appt_line_items(user, results)

  #       with true <- is_binary(next),
  #            %{query: query} when is_binary(query) <- URI.parse(next),
  #            %{"cursor" => new_cursor} when is_binary(new_cursor) <- URI.decode_query(query) do
  #         get_no_shows_for_month(user, month, start_day, end_day, new_cursor)
  #       else
  #         false ->
  #           IO.puts("finished")

  #         err ->
  #           IO.inspect(next)
  #           IO.inspect(err)
  #       end

  #     {:ok, error} ->
  #       error
  #   end
  # end

  # defp update_appt_line_items(user, results) do
  #   Enum.map(results, fn appt ->
  #     get_appt_line_items(user, appt["id"])
  #   end)
  # end

  # def get_appt(user, id) do
  #   base_uri = "https://drchrono.com/api/appointments"

  #   {:ok, %{body: resp}} =
  #     HTTPoison.get(base_uri <> "/" <> to_string(id), [
  #       {"Authorization", "Bearer #{user.drchrono_oauth_token}"}
  #     ])

  #   case Jason.decode(resp) do
  #     {:ok, results} ->
  #       results

  #     error ->
  #       error
  #   end
  # end

  # defp get_appt_line_items(user, appt_id) do
  #   base_uri = "https://drchrono.com/api/line_items"

  #   {:ok, %{body: resp}} =
  #     HTTPoison.get(base_uri <> "?appointment=#{appt_id}", [
  #       {"Authorization", "Bearer #{user.drchrono_oauth_token}"}
  #     ])

  #   case Jason.decode(resp) do
  #     {:ok, %{"results" => line_items}} ->
  #       case Enum.split_with(line_items, &(&1["code"] in no_show_codes())) do
  #         {[], _} ->
  #           # no no_show code line item was present. do nothing
  #           nil

  #         {_, []} ->
  #           # all line items are no_shows. do nothing
  #           nil

  #         {_no_show_items, other_items} ->
  #           # there are no_shows and other line items. need to delete all other_items
  #           Enum.map(other_items, fn item ->
  #             delete_line_item(user, item)
  #           end)
  #       end

  #     error ->
  #       IO.inspect(error)
  #   end
  # end

  # defp no_show_codes do
  #   ["00001", "00002", "00003"]
  # end

  # defp delete_line_item(_user, %{"id" => line_item_id} = line_item) do
  #   IO.puts("deleting line item ID: #{line_item_id}")
  #   Mindful.Utilities.create_deleted_line_item(line_item)

  #   # base_uri = "https://app.drchrono.com/api/line_items"
  #   # WARNING: THIS CODE DELETES DATA FROM DR CHRONO
  #   # {:ok, %{body: resp, status_code: status_code}} =
  #   #   HTTPoison.delete(
  #   #     base_uri <> "/" <> to_string(line_item_id),
  #   #     [{"Authorization", "Bearer #{user.drchrono_oauth_token}"}]
  #   #   )

  #   # IO.inspect(resp)
  #   # IO.inspect(status_code)
  # end

  def fetch_name_for_office(office_id) when is_integer(office_id) do
    base_uri = "https://drchrono.com/api/offices"
    token = TokensCache.get_drchrono_token()

    if token do
      {:ok, %{body: resp}} =
        HTTPoison.get(base_uri <> "/" <> to_string(office_id), [
          {"Authorization", "Bearer #{token}"}
        ])

      case Jason.decode(resp) do
        {:ok, %{"name" => name}} ->
          name

        error ->
          error
      end
    end
  end

  def fetch_name_for_office(_), do: nil

  def fetch_name_for_provider(provider_id) when is_integer(provider_id) do
    base_uri = "https://drchrono.com/api/doctors"
    token = TokensCache.get_drchrono_token()

    if token do
      {:ok, %{body: resp}} =
        HTTPoison.get(base_uri <> "/" <> to_string(provider_id), [
          {"Authorization", "Bearer #{token}"}
        ])

      case Jason.decode(resp) do
        {:ok, %{"first_name" => first_name, "last_name" => last_name}} ->
          first_name <> " " <> last_name

        {:ok, %{"detail" => detail}} when is_binary(detail) ->
          raise "Error when fetching name of provider. Error detail: #{detail}"

        {:error, %{data: error}} ->
          raise "Error when fetching name of provider. Error data: #{error}"
      end
    end
  end

  def fetch_name_for_provider(_), do: nil

  @spec fetch_appointments_for_provider(integer(), map()) :: list()
  def fetch_appointments_for_provider(provider_id, params \\ %{})

  def fetch_appointments_for_provider(provider_id, params) when is_integer(provider_id) do
    base_uri = "https://drchrono.com/api/appointments"
    token = TokensCache.get_drchrono_token()

    if token do
      headers = [{"Authorization", "Bearer #{token}"}]
      page_size = Map.get(params, :page_size, 20)

      query_params =
        params
        |> parse_date_params()
        |> Map.merge(%{page_size: page_size, doctor: provider_id})
        |> prepare_query_string()

      with {:ok, %{body: resp}} <- HTTPoison.get(base_uri <> query_params, headers),
           {:ok, %{"data" => results}} <- Jason.decode(resp) do
        {:ok, results}
      end
    else
      {:ok, []}
    end
  end

  def fetch_appointments_for_provider(_, _), do: []

  def fetch_problems(patient_id) do
    base_uri = "https://drchrono.com/api/problems"
    query_params = "?patient=#{patient_id}"
    token = TokensCache.get_drchrono_token()

    if token do
      {:ok, %{body: resp}} =
        HTTPoison.get(base_uri <> query_params, [
          {"Authorization", "Bearer #{token}"}
        ])

      case Jason.decode(resp) do
        {:ok, %{"results" => []}} ->
          []

        {:ok, %{"results" => problems}} when is_list(problems) ->
          Enum.map(problems, & &1["name"])

        {:ok, %{"detail" => detail}} when is_binary(detail) ->
          raise "Error when fetching problems. Error detail: #{detail}"

        {:error, %{data: error}} ->
          raise "Error when fetching problems. Error data: #{error}"
      end
    end
  end

  def fetch_medications(patient_id) do
    base_uri = "https://drchrono.com/api/medications"
    query_params = "?patient=#{patient_id}"
    token = TokensCache.get_drchrono_token()

    if token do
      {:ok, %{body: resp}} =
        HTTPoison.get(base_uri <> query_params, [
          {"Authorization", "Bearer #{token}"}
        ])

      case Jason.decode(resp) do
        {:ok, %{"results" => []}} ->
          []

        {:ok, %{"results" => medications}} when is_list(medications) ->
          Enum.map(medications, & &1["name"])

        {:ok, %{"detail" => detail}} when is_binary(detail) ->
          raise "Error when fetching meds. Error detail: #{detail}"

        {:error, %{data: error}} ->
          raise "Error when fetching meds. Error data: #{error}"
      end
    end
  end

  def fetch_next_appointment(patient_id) when is_integer(patient_id) do
    base_uri = "https://drchrono.com/api/appointments"
    token = TokensCache.get_drchrono_token()
    today = Timex.today()
    six_months_later = Timex.shift(today, months: 6)

    params =
      "?date_range=#{today.year}-#{today.month}-#{today.day}%2f#{six_months_later.year}-#{six_months_later.month}-#{six_months_later.day}&patient=#{patient_id}&page_size=50"

    {:ok, %{body: resp}} =
      HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}])

    case Jason.decode(resp) do
      {:ok, %{"results" => []}} ->
        nil

      {:ok, %{"results" => appts}} when is_list(appts) ->
        [next_appt | _] =
          appts
          |> Enum.map(&Timex.parse!(&1["scheduled_time"], "{ISO:Extended}"))
          |> Enum.sort(Date)

        Timex.format!(next_appt, "{YYYY}-{0M}-{0D}")

      {:ok, %{"detail" => detail}} when is_binary(detail) ->
        raise "Error when fetching next appointment. Error detail: #{detail}"

      {:error, %{data: error}} ->
        raise "Error when fetching next appointment. Error data: #{error}"
    end
  end

  # def wrong_status_appointment_ids do
  #   [
  #     "170133945"
  #   ]
  # end

  # def complete_appt_status(user, id) do
  #   base_uri = "https://drchrono.com/api/appointments"

  #   appt = get_appt(user, id)
  #   IO.inspect(appt)

  #   body =
  #     Jason.encode!(%{
  #       status: "Complete"
  #     })

  #   {:ok, %{body: "", status_code: 204}} =
  #     HTTPoison.patch(base_uri <> "/" <> to_string(id), body, [
  #       {"Content-Type", "application/json"},
  #       {"Authorization", "Bearer #{user.drchrono_oauth_token}"}
  #     ])

  #   # IO.inspect(resp)

  #   # case Jason.decode(resp) do
  #   #   {:ok, results} ->
  #   #     results

  #   #   error ->
  #   #     error
  #   # end
  # end

  # def update_appointment_statuses(user) do
  #   Enum.map(wrong_status_appointment_ids, fn appt_id ->
  #     complete_appt_status(user, appt_id)
  #   end)
  # end
  #

  ## Private Functions

  defp parse_date_params(%{date: date} = params),
    do: Map.put(params, :date, "#{date.year}-#{date.month}-#{date.day}")

  defp parse_date_params(params) do
    since = Map.get(params, :since, Date.utc_today())
    until = Map.get(params, :until, Date.add(since, 1))

    range =
      "#{since.year}-#{since.month}-#{since.day}%2f#{until.year}-#{until.month}-#{until.day}"

    Map.put(params, :date_range, range)
  end

  defp prepare_query_string(params) do
    Enum.reduce(params, "?", fn {k, v}, acc ->
      acc <> "#{k}=#{v}&"
    end)
  end
end
