defmodule MindfulWeb.HelpScoutAdapter do
  @moduledoc """
  Adapter to integrate with Help Scout API
  """

  alias MindfulWeb.Services.TokensCache

  def generate_token do
    client_secret = Application.get_env(:mindful, :helpscout)[:secret]
    client_id = Application.get_env(:mindful, :helpscout)[:id]
    base_uri = "https://api.helpscout.net/v2/oauth2/token"

    body =
      %{client_secret: client_secret, grant_type: "client_credentials", client_id: client_id}
      |> Jason.encode!()

    with {:ok, %{body: resp}} <-
           HTTPoison.post(base_uri, body, [{"Content-Type", "application/json"}]),
         {:ok, %{"access_token" => token, "expires_in" => timeout}} <- Jason.decode(resp) do
      {token, timeout}
    else
      _err ->
        raise "Failed to generate token."
    end
  end

  def get_customer_by_email(email) do
    url = "https://api.helpscout.net/v2/customers"
    query_params = "?email=#{email}"
    token = TokensCache.fetch_help_scout_token()

    {:ok, %{body: resp}} =
      HTTPoison.get(url <> query_params, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])

    case Jason.decode(resp) do
      {:ok, %{"_embedded" => %{"customers" => [customer]}}} -> customer
      {:ok, %{"_embedded" => %{"customers" => [customer | _]}}} -> customer
      _ -> nil
    end
  end

  def get_customer_by_phone(phone) do
    phone = phone |> String.replace(~r/\s+/, " ")
    url = "https://api.helpscout.net/v2/customers"
    query_params = "?query=(phone:#{phone})"
    token = TokensCache.fetch_help_scout_token()

    {:ok, %{body: resp}} =
      HTTPoison.get(url <> query_params, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])

    case Jason.decode(resp) do
      {:ok, %{"_embedded" => %{"customers" => [customer]}}} ->
        customer

      {:ok, %{"_embedded" => %{"customers" => [customer | _]}}} ->
        customer

      _ ->
        nil
    end
  end

  def reassign_conversation(base_uri, customer_id) do
    base_uri = base_uri

    body =
      Jason.encode!(%{
        "op" => "replace",
        "path" => "/primaryCustomer.id",
        "value" => customer_id
      })

    token = TokensCache.fetch_help_scout_token()

    {:ok, %{body: _resp}} =
      HTTPoison.patch(base_uri, body, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])
  end

  def create_or_update_customer(patient) do
    if customer = get_customer_by_email(patient.email) do
      update_customer_fields(customer, patient)
      update_customer_properties(customer, patient)
    else
      create_customer_from_patient(patient)
    end
  end

  def create_customer_from_patient(patient) do
    base_uri = "https://api.helpscout.net/v2/customers"
    body = Jason.encode!(new_customer_body(patient))
    token = TokensCache.fetch_help_scout_token()

    # for test purposes, filter on email
    # if String.starts_with?(patient.email, "testmc1") do
    {:ok, %{body: _resp}} =
      HTTPoison.post(base_uri, body, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])
  end

  defp new_customer_body(patient) do
    %{
      first_name: patient.first_name,
      last_name: patient.last_name,
      emails: [%{type: "work", value: patient.email}],
      # Don't add address information when creating. HelpScout will reject it
      # if the city, state, country, or postalCode are empty.
      # address: %{
      #   city: patient["city"],
      #   state: patient["state"],
      #   postal_code: patient["zip_code"],
      #   country: "US",
      #   lines: [patient["address"]]
      # },
      phones: [%{type: "work", value: patient.phone}],
      properties: [
        %{slug: "DateOfBirth", value: patient.dob},
        %{slug: "Diagnosis", value: patient.diagnosis},
        %{slug: "FirstAppointmentDate", value: patient.first_appointment_date},
        %{slug: "LastAppointmentDate", value: patient.last_appointment_date},
        %{slug: "Medication", value: patient.medication},
        %{slug: "NextAppointmentDate", value: patient.next_appointment_date},
        %{slug: "OfficeLocation", value: patient.office},
        %{slug: "Provider", value: patient.provider}
      ]
    }
    |> weed_out_nil_create_fields()
  end

  def update_customer_fields(customer, patient) do
    base_uri = "https://api.helpscout.net/v2/customers/" <> Integer.to_string(customer["id"])
    body = Jason.encode!(merge_patient_into_customer(patient, "replace", :fields))
    token = TokensCache.fetch_help_scout_token()

    # conditionally update only my test customer in helpscout for now
    # if String.starts_with?(patient.email, "testmc1") do
    {:ok, %{body: resp}} =
      HTTPoison.patch(base_uri, body, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])

    case Jason.decode(resp) do
      {:error, %Jason.DecodeError{data: ""}} ->
        # successfully updated customer when only thing returned is an empty string
        :ok

      {:ok, %{"message" => "Conflict - entity cannot be created"}} ->
        # Don't do anything in this case. It happens when requests are sent back to back quickly for the same email
        nil

      {:ok, _result} ->
        raise "Failed to update customer fields. Map is above ^"
    end

    # end
  end

  def update_customer_properties(customer, patient) do
    base_uri =
      "https://api.helpscout.net/v2/customers/" <>
        Integer.to_string(customer["id"]) <> "/properties"

    body = Jason.encode!(merge_patient_into_customer(patient, "replace", :properties))

    token = TokensCache.fetch_help_scout_token()

    # conditionally update only my test customer in helpscout for now
    # if patient.email == "mcadenhead@mindful.care" do
    {:ok, %{body: resp}} =
      HTTPoison.patch(base_uri, body, [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ])

    case Jason.decode(resp) do
      {:error, %Jason.DecodeError{data: ""}} ->
        # successfully updated customer when only thing returned is an empty string
        nil

      {:ok, _result} ->
        raise "Failed to update customer properties. Map is above ^"
    end

    # end
  end

  def merge_patient_into_customer(patient, op, :fields) do
    patient
    |> customer_fields(op)
    |> weed_out_nil_fields()
    |> Enum.reject(&is_nil(&1["value"]))
  end

  def merge_patient_into_customer(patient, op, :properties) do
    patient
    |> customer_properties(op)
    |> weed_out_nil_fields()
    |> Enum.reject(&is_nil(&1["value"]))
  end

  # these are the built-in HelpScout user fields
  defp customer_fields(customer, op) do
    [
      %{
        "op" => op,
        "path" => "/firstName",
        "value" => customer.first_name
      },
      %{
        "op" => op,
        "path" => "/lastName",
        "value" => customer.last_name
      },
      # HelpScout api won't let you easily replace a phone so remove the phones/1 phone and add a new phone.
      %{
        "op" => "remove",
        "path" => "/phones/1"
      },
      %{
        "op" => "add",
        "path" => "/phones",
        "value" => %{
          "type" => "mobile",
          "value" => customer.phone
        }
      },
      %{
        "op" => op,
        "path" => "/address/city",
        "value" => customer.city
      },
      %{
        "op" => op,
        "path" => "/address/country",
        "value" => customer.country
      },
      %{
        "op" => op,
        "path" => "/address/lines",
        "value" => customer.lines
      },
      %{
        "op" => op,
        "path" => "/address/postalCode",
        "value" => customer.zip
      },
      %{
        "op" => op,
        "path" => "/address/state",
        "value" => customer.state
      }
    ]
  end

  # these are custom properties we defined in HelpScout
  defp customer_properties(customer, op) do
    [
      %{
        "op" => op,
        "path" => "/DateOfBirth",
        "value" => customer.dob
      },
      %{
        "op" => op,
        "path" => "/FirstAppointmentDate",
        "value" => customer.first_appointment_date
      },
      %{
        "op" => op,
        "path" => "/LastAppointmentDate",
        "value" => customer.last_appointment_date
      },
      %{
        "op" => op,
        "path" => "/OfficeLocation",
        "value" => customer.office
      },
      %{
        "op" => op,
        "path" => "/Provider",
        "value" => customer.provider
      },
      %{
        "op" => op,
        "path" => "/Diagnosis",
        "value" => customer.diagnosis
      },
      %{
        "op" => op,
        "path" => "/Medication",
        "value" => customer.medication
      },
      %{
        "op" => op,
        "path" => "/NextAppointmentDate",
        "value" => customer.next_appointment_date
      }
    ]
  end

  # weed out any fields that are nil or blank so we aren't updating fields with nil values
  defp weed_out_nil_fields(fields) do
    Enum.reduce(fields, [], fn field, acc ->
      case field["value"] do
        nil ->
          acc

        "" ->
          acc

        [val] ->
          case Jason.decode(val) do
            {:ok, []} ->
              acc

            {:ok, _} ->
              [field | acc]

            {:error, _} ->
              acc
          end

          acc

        val when is_binary(val) ->
          [field | acc]

        %{"value" => nil} ->
          acc

        %{"value" => ""} ->
          acc

        _ ->
          [field | acc]
      end
    end)
  end

  # weed out fields that are empty when creating a new customer
  defp weed_out_nil_create_fields(map) do
    Enum.reduce(map, %{}, fn
      {_k, nil}, acc ->
        acc

      {_k, ""}, acc ->
        acc

      {_k, []}, acc ->
        acc

      {k, v}, acc when is_binary(v) ->
        Map.put(acc, k, v)

      {k, v}, acc when is_list(v) ->
        present_values = Enum.reject(v, &(&1.value in [nil, "", []]))

        if present_values == [] do
          acc
        else
          Map.put(acc, k, present_values)
        end

      {k, v}, acc when is_map(v) ->
        present_values =
          Enum.into(Enum.reject(v, fn {_, value} -> value in [nil, "", [], [""]] end), %{}, & &1)

        Map.put(acc, k, present_values)
    end)
  end
end
