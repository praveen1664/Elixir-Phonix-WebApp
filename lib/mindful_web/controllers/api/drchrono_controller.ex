defmodule MindfulWeb.API.DrchronoController do
  @moduledoc """
  Listens for post requests from Dr Chrono.
  """

  use MindfulWeb, :controller

  alias Mindful.ChronoSchemas

  @doc """
  Dr. Chrono requires manually verifying the authenticity of the webhook url first through a get request.
  """
  def verify(conn, %{"msg" => msg}) do
    secret = Application.get_env(:mindful, :drchrono)[:webhook_secret]
    hashed_msg = :crypto.mac(:hmac, :sha256, secret, msg) |> Base.encode16() |> String.downcase()
    response = Jason.encode!(%{secret_token: hashed_msg})

    send_resp(conn, 200, response)
  end

  @doc """
  Processes webhook events from Dr Chrono.
  """
  def index(conn, params) do
    [event] = get_req_header(conn, "x-drchrono-event")

    IO.puts(event)
    IO.inspect(params["object"])

    drchrono_patient_uuid =
      cond do
        event in ["PATIENT_CREATE", "PATIENT_MODIFY"] ->
          drchrono_patient = ChronoSchemas.upsert_patient!(params["object"])
          drchrono_patient.uuid

        event in ["APPOINTMENT_CREATE", "APPOINTMENT_MODIFY", "APPOINTMENT_DELETE"] ->
          drchrono_appointment = ChronoSchemas.upsert_appointment!(params["object"])
          drchrono_appointment.patient

        event in ["PATIENT_MEDICATION_CREATE", "PATIENT_MEDICATION_MODIFY"] ->
          drchrono_medication = ChronoSchemas.upsert_medication!(params["object"])
          drchrono_medication.patient

        event in ["PATIENT_PROBLEM_CREATE", "PATIENT_PROBLEM_MODIFY"] ->
          drchrono_problem = ChronoSchemas.upsert_problem!(params["object"])
          drchrono_problem.patient

        event in ["LINE_ITEM_CREATE", "LINE_ITEM_MODIFY", "LINE_ITEM_DELETE"] ->
          ChronoSchemas.upsert_line_item!(params["object"])
          nil
      end

    if drchrono_patient_uuid do
      nil
      # patient_map = fill_patient_map(drchrono_patient_uuid)
      # warning: when our database is not in sync with drchrono, updating patient info across services
      # when we don't have their latest info can lead to overwriting existing data in those services
      # HelpScout.create_or_update_customer(patient_map)
      # AC.create_or_update_contact(patient_map)
    end

    send_resp(conn, 200, "ok")
  end

  def problems_stringified(problems) when is_list(problems) do
    # make list of problems unique until todo for query is fixed to not get duplicates
    diagnosis = problems |> Enum.uniq() |> Enum.join(" | ")

    if diagnosis != "" do
      if String.length(diagnosis) < 200 do
        diagnosis
      else
        String.slice(diagnosis, 0, 185) <> "... and more"
      end
    end
  end

  def problems_stringified(_), do: nil

  defp meds_stringified(meds) when is_list(meds) do
    # make list of meds unique until todo for query is fixed to not get duplicates
    meds = meds |> Enum.uniq() |> Enum.join(" | ")

    if meds != "" do
      if String.length(meds) < 200 do
        meds
      else
        String.slice(meds, 0, 185) <> "... and more"
      end
    end
  end

  defp meds_stringified(_), do: nil

  defp get_phone(drchrono_patient) do
    drchrono_patient.cell_phone || drchrono_patient.home_phone ||
      drchrono_patient.office_phone
  end

  def fill_patient_map(drchrono_patient_uuid) do
    drchrono_data = ChronoSchemas.get_patient_to_broadcast(drchrono_patient_uuid)

    problems = Enum.uniq(drchrono_data.problems)
    meds = Enum.uniq(drchrono_data.medications)

    next_appt_date =
      if drchrono_data.future_appointments do
        drchrono_data.future_appointments
        |> Enum.sort_by(& &1, {:asc, Date})
        |> List.first()
      end

    %{
      first_name: drchrono_data.patient.first_name,
      last_name: drchrono_data.patient.last_name,
      email: drchrono_data.patient.email,
      phone: get_phone(drchrono_data.patient),
      city: drchrono_data.patient.city,
      state: drchrono_data.patient.state,
      zip: drchrono_data.patient.zip_code,
      country: "US",
      lines: [drchrono_data.patient.address],
      dob: drchrono_data.patient.date_of_birth,
      diagnosis: problems_stringified(problems),
      first_appointment_date: drchrono_data.patient.date_of_first_appointment,
      last_appointment_date: drchrono_data.patient.date_of_last_appointment,
      medication: meds_stringified(meds),
      next_appointment_date: next_appt_date,
      office: if(drchrono_data.office, do: List.first(drchrono_data.office)),
      provider: drchrono_data.doctor
    }
  end
end
