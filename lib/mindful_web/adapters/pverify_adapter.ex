defmodule MindfulWeb.PverifyAdapter do
  @moduledoc """
  Adapter for working with pVerify
  """
  alias Mindful.{Accounts, Pverify}

  @valid_eligibility_types ["Active Coverage", "Co-Insurance", "Co-Payment"]
  @healthfirst_payer_codes ["000924", "000925", "00110", "00234"]

  defp client_id() do
    Application.get_env(:mindful, :pverify)[:client_id] || "cf0df2c8-0650-4efe-9f5c-31c6dc954efb"
  end

  defp secret() do
    Application.get_env(:mindful, :pverify)[:secret] || "teYuStj7UYLkK21DLnxJKO7gSa2Vg"
  end

  defp token_headers(), do: [{"Content-Type", "application/x-www-form-urlencoded"}]

  defp api_headers(token) do
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Client-API-Id", client_id()}
    ]
  end

  def generate_token() do
    url = "https://api.pverify.com/Token"
    body = "Client_Id=#{client_id()}&Client_Secret=#{secret()}&grant_type=client_credentials"

    with {:ok, %{body: resp}} <- HTTPoison.post(url, body, token_headers()),
         {:ok, %{"access_token" => token, "expires_in" => timeout}} <- Jason.decode(resp) do
      {token, timeout}
    else
      _err ->
        raise "Failed to generate token."
    end
  end

  # Use DrChrono data as source of truth for firstName and lastName if available
  # For dob, it will be identical since we did a db write
  @callback verify_eligibility(User.t(), String.t(), struct()) :: {:ok, any()} | {:error, any()}
  def verify_eligibility(user, token) do
    url = "https://api.pverify.com/API/EligibilitySummary"
    body = prepare_request_body(user)

    with {:ok, %{body: resp}} <- HTTPoison.post(url, body, api_headers(token)) do
      resp = resp |> Jason.decode!()

      cond do
        resp["message"] && resp["message"] =~ "Payer is invalid" ->
          {:error, :invalid_payer}

        resp["message"] && resp["message"] =~ "Authorization has been denied for this request" ->
          {:error, :unauthorized}

        resp["message"] &&
            resp["message"] =~ "Insufficient information to generate patient search" ->
          {:error, :patient_search_failed}

        resp["APIResponseMessage"] &&
            resp["APIResponseMessage"] =~ "Error occurred while connecting to carrier" ->
          {:error, :connection_failed}

        resp["APIResponseMessage"] &&
            resp["APIResponseMessage"] =~ "Invalid/Missing Subscriber/Insured ID" ->
          {:error, :invalid_subscriber_id}

        resp["APIResponseMessage"] &&
            resp["APIResponseMessage"] =~ "Invalid/Missing Subscriber/Insured Name" ->
          {:error, :invalid_subscriber_name}

        true ->
          %{has_active_coverage: has_active_coverage} = data = process_response_data(user, resp)
          {:ok, _} = Pverify.store_pverify_response_data(user, data)

          if has_active_coverage do
            {:ok, _} =
              Accounts.update_user_pverify_verification_status(user, %{
                pverify_eligibility_verified: true
              })
          end

          {:ok, data}
      end
    else
      err ->
        err
    end
  end

  defp prepare_request_body(user) do
    %{
      "subscriber" => %{
        "firstName" => user.first_name,
        "lastName" => user.last_name,
        "dob" => user.dob,
        "memberID" => user.user_pverify_data.subscriber_member_id
      },
      "provider" => %{
        "lastName" => user.user_pverify_data.provider_name,
        "npi" => user.user_pverify_data.provider_npi
      },
      "payerCode" => user.user_pverify_data.payer_code,
      "Location" => user.state.name,
      "doS_StartDate" => user.user_pverify_data.dos_start_date,
      "doS_EndDate" => user.user_pverify_data.dos_end_date,
      "isSubscriberPatient" => user.user_pverify_data.is_subscriber_patient
    }
    |> Jason.encode!()
  end

  defp process_response_data(user, response) do
    %{"ServiceDetails" => serviceDetails} = response

    eligibility_details =
      user |> get_service_details(serviceDetails) |> extract_eligibility_details()

    hbpc = extract_hbpc_details(serviceDetails)
    other_payer_info = response["OtherPayerInfo"]

    has_active_coverage =
      check_for_active_coverage(
        eligibility_details,
        other_payer_info,
        user.user_pverify_data.payer_code,
        hbpc
      )

    co_ins_in_net = response |> get_in(["MentalHealthSummary", "CoInsInNet", "Value"])
    co_pay_in_net = response |> get_in(["MentalHealthSummary", "CoPayInNet", "Value"])

    individual_deductible_in_net =
      response |> get_in(["HBPC_Deductible_OOP_Summary", "IndividualDeductibleInNet", "Value"])

    individual_deductible_remaining_in_net =
      response
      |> get_in(["HBPC_Deductible_OOP_Summary", "IndividualDeductibleRemainingInNet", "Value"])

    individual_oop_remaining_in_net =
      response |> get_in(["HBPC_Deductible_OOP_Summary", "IndividualOOPRemainingInNet", "Value"])

    eligibility_details = populate_additional_info_if_needed(response, eligibility_details)

    %{
      eligibility_details: eligibility_details,
      has_active_coverage: has_active_coverage,
      co_insurance_in_net: co_ins_in_net,
      co_pay_in_net: co_pay_in_net,
      individual_deductible_in_net: individual_deductible_in_net,
      individual_deductible_remaining_in_net: individual_deductible_remaining_in_net,
      individual_oop_remaining_in_net: individual_oop_remaining_in_net,
      is_hmo_plan: response["IsHMOPlan"],
      plan_coverage_summary: response["PlanCoverageSummary"],
      other_payer_info: other_payer_info
    }
  end

  defp extract_hbpc_details(serviceDetails) do
    serviceDetails
    |> Enum.find([], &(&1["ServiceName"] == "Health Benefit Plan Coverage"))
  end

  # If patient has no eligibility details, block self-verification
  defp check_for_active_coverage([], _otherPayerInfo, _payer_code, _hbpc), do: false

  # If there is no other PrimaryPayer mentioned in Pverify response, patient may be able to self-verify
  defp check_for_active_coverage(eligibility_details, nil, payer_code, _hbpc)
       when payer_code not in @healthfirst_payer_codes do
    eligibility_details
    |> Enum.any?(&Enum.member?(@valid_eligibility_types, &1["EligibilityOrBenefit"]))
  end

  defp check_for_active_coverage(
         eligibility_details,
         %{"PrimaryPayer" => nil} = _otherPayerInfo,
         payer_code,
         _hbpc
       )
       when payer_code not in @healthfirst_payer_codes do
    eligibility_details
    |> Enum.any?(&Enum.member?(@valid_eligibility_types, &1["EligibilityOrBenefit"]))
  end

  # Custom logic for Healthfirst payers
  # Do not allow patient to self-verify if any PlanCoverageDescription is "SENIOR HEALTH PARTNERS"
  defp check_for_active_coverage(
         _eligibility_details,
         otherPayerInfo,
         payer_code,
         hbpc
       )
       when payer_code in @healthfirst_payer_codes do
    primary_payer = otherPayerInfo["PrimaryPayer"]

    is_under_senior_health_partners_plan =
      hbpc
      |> Map.get("EligibilityDetails", [])
      |> Enum.any?(&(&1["PlanCoverageDescription"] == "SENIOR HEALTH PARTNERS"))

    cond do
      is_under_senior_health_partners_plan -> false
      true -> is_nil(primary_payer)
    end
  end

  # If there is another PrimaryPayer mentioned in Pverify response, do not allow patient to self-verify
  defp check_for_active_coverage(_eligibility_details, _otherPayerInfo, _payerCode, _hbpc) do
    false
  end

  defp extract_eligibility_details(%{"EligibilityDetails" => nil} = _data), do: []

  defp extract_eligibility_details(%{"EligibilityDetails" => details} = _data) do
    details
    |> Enum.map(fn item ->
      %{
        "AuthorizationOrCertificationRequired" => item["AuthorizationOrCertificationRequired"],
        "CoverageLevel" => item["CoverageLevel"],
        "EligibilityOrBenefit" => item["EligibilityOrBenefit"],
        "MonetaryAmount" => item["MonetaryAmount"],
        "Message" => item["Message"]
      }
    end)
  end

  defp extract_eligibility_details(_data), do: []

  # If patient has no eligibility details, store the additional info provided by Pverify
  defp populate_additional_info_if_needed(response, []) do
    [%{"AdditionalInfo" => response["AddtionalInfo"]}]
  end

  defp populate_additional_info_if_needed(_response, details), do: details

  defp get_service_details(user, serviceDetails) do
    payer_code = user.user_pverify_data.payer_code
    # TODO: Implement custom ServiceName logic for other payers

    cond do
      # Aetna
      payer_code == "00001" ->
        serviceDetails
        |> Enum.find(&(&1["ServiceName"] == "Mental Health Provider  - Outpatient"))

      # United Healthcare - Optum Behavioral Solutions
      payer_code == "UHG007" ->
        serviceDetails
        |> Enum.find(&(&1["ServiceName"] == "Psychiatric"))

      true ->
        serviceDetails
        |> Enum.find(%{}, &(&1["ServiceName"] == "Mental Health"))
    end
  end
end
