defmodule MindfulWeb.ActiveCampaignAdapter do
  @moduledoc """
   Adapter to integrate with Active Campaign API.

   Rate limits and API guidance at https://developers.activecampaign.com/reference#rate-limits
  """

  def create_or_update_contact(patient) do
    patient |> prepare_patient_create_or_update() |> create_or_update()
  end

  defp prepare_patient_create_or_update(patient) do
    %{
      "contact" => %{
        "email" => patient.email,
        "firstName" => patient.first_name,
        "lastName" => patient.last_name,
        "phone" => patient.phone,
        "fieldValues" => [
          # field IDs are unique and found by doing a GET request: https://developers.activecampaign.com/reference#retrieve-fields-1
          %{
            "field" => 11,
            "title" => "Provider",
            "value" => patient.provider,
            "visible" => 0
          },
          %{
            "field" => 34,
            "title" => "Office",
            "value" => patient.office,
            "visible" => 0
          },
          %{
            "field" => 6,
            "title" => "City",
            "value" => patient.city,
            "visible" => 0
          },
          %{
            "field" => 7,
            "title" => "State",
            "value" => patient.state,
            "visible" => 0
          },
          %{
            "field" => 4,
            "title" => "Zip Code",
            "value" => patient.zip,
            "visible" => 0
          },
          %{
            "field" => 2,
            "title" => "Date of Birth",
            "value" => patient.dob,
            "visible" => 0
          },
          %{
            "field" => 12,
            "title" => "Diagnosis",
            "value" => patient.diagnosis,
            "visible" => 0
          },
          %{
            "field" => 13,
            "title" => "Medication",
            "value" => patient.medication,
            "visible" => 0
          },
          %{
            "field" => 32,
            "title" => "First Appointment Date",
            "value" => patient.first_appointment_date,
            "visible" => 0
          },
          %{
            "field" => 35,
            "title" => "Last Appointment Date",
            "value" => patient.last_appointment_date,
            "visible" => 0
          },
          %{
            "field" => 36,
            "title" => "Next Appointment Date",
            "value" => patient.next_appointment_date,
            "visible" => 0
          }
        ]
      }
    }
  end

  def create_or_update(body) do
    body = body |> Jason.encode!()
    api_key = :mindful |> Application.get_env(:activecampaign) |> Keyword.get(:api_key)
    base_url = :mindful |> Application.get_env(:activecampaign) |> Keyword.get(:base_url)

    {:ok, _response} =
      HTTPoison.post(
        "#{base_url}/api/3/contact/sync",
        body,
        [{"Api-Token", api_key}, {"Content-Type", "application/json"}]
      )
  end
end
