defmodule MindfulWeb.Services.DrchronoDbCopier do
  @moduledoc """
  Used alongside Quantum to schedule regular backups of Drchrono.com data to our production database.
  """

  import Ecto.Query
  alias Mindful.Repo

  alias Mindful.ChronoSchemas.{
    DrchronoPatient,
    DrchronoAppointment,
    DrchronoProcedure,
    DrchronoLineItem,
    DrchronoOffice,
    DrchronoDoctor,
    DrchronoAppointmentProfile,
    DrchronoMedication,
    DrchronoProblem
  }

  @doc """
  Deletes stale Drchrono data from our database.
  """
  def delete_stale_data do
    Task.start(fn -> delete_drchrono_data() end)
  end

  defp delete_drchrono_data do
    Repo.delete_all(DrchronoPatient)
    Repo.delete_all(DrchronoAppointment)
    Repo.delete_all(DrchronoLineItem)
    Repo.delete_all(DrchronoOffice)
    Repo.delete_all(DrchronoDoctor)
    Repo.delete_all(DrchronoAppointmentProfile)
    Repo.delete_all(DrchronoProcedure)
    Repo.delete_all(DrchronoProblem)
    Repo.delete_all(DrchronoMedication)
  end

  @doc """
  Go through each Drchrono resource and insert the resulting lists into our db.
  """
  def copy_all_data do
    # Task.start(fn -> insert_drchrono_data() end)
    insert_drchrono_data()
  end

  def insert_drchrono_data do
    download_patients()
    # other functions need a list of drchrono doctor_ids for querying so download them before
    download_doctors()
    download_appointments()
    download_offices()
    download_appointment_profiles()
    download_procedures()
    download_line_items()
    download_problems()
    download_medications()
  end

  # Fetches patients from Drchrono and inserts them into our database.
  def download_patients(cursor \\ nil) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/patients"

    case HTTPoison.get(base_uri <> "?verbose=true", [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        patients = Enum.map(data, &normalize_patient_data(&1))
        IO.puts("Downloading #{length(patients)} patients")

        Repo.insert_all(DrchronoPatient, patients,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor, do: download_patients(next_cursor), else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_patients(cursor)
    end
  end

  def normalize_patient_data(drchrono_patient) do
    %{
      uuid: drchrono_patient["id"],
      first_name: drchrono_patient["first_name"],
      last_name: drchrono_patient["last_name"],
      date_of_birth: cast_to_datetime(drchrono_patient["date_of_birth"]),
      primary_care_physician: drchrono_patient["primary_care_physician"],
      home_phone: drchrono_patient["home_phone"],
      cell_phone: drchrono_patient["cell_phone"],
      office_phone: drchrono_patient["office_phone"],
      email: drchrono_patient["email"],
      gender: drchrono_patient["gender"],
      address: drchrono_patient["address"],
      city: drchrono_patient["city"],
      state: drchrono_patient["state"],
      zip_code: drchrono_patient["zip_code"],
      doctor: drchrono_patient["doctor"],
      copay: string_to_float(drchrono_patient["copay"]),
      ethnicity: drchrono_patient["ethnicity"],
      patient_status: drchrono_patient["patient_status"],
      race: drchrono_patient["race"],
      date_of_first_appointment: cast_to_datetime(drchrono_patient["date_of_first_appointment"]),
      date_of_last_appointment: cast_to_datetime(drchrono_patient["date_of_last_appointment"]),
      referring_source: drchrono_patient["referring_source"],
      primary_insurance_payer_id: drchrono_patient["primary_insurance"]["insurance_payer_id"],
      primary_insurance_company: drchrono_patient["primary_insurance"]["insurance_company"],
      primary_insurance_group_name: drchrono_patient["primary_insurance"]["insurance_group_nam"],
      primary_insurance_plan_name: drchrono_patient["primary_insurance"]["insurance_plan_name"],
      primary_insurance_is_subscriber_the_patient:
        drchrono_patient["primary_insurance"]["is_subscriber_the_patient"],
      primary_insurance_patient_relationship_to_subscriber:
        drchrono_patient["primary_insurance"]["patient_relationship_to_subscriber"],
      primary_insurance_subscriber_state:
        drchrono_patient["primary_insurance"]["subscriber_state"],
      secondary_insurance_payer_id: drchrono_patient["secondary_insurance"]["payer_id"],
      secondary_insurance_company: drchrono_patient["secondary_insurance"]["insurance_company"],
      secondary_insurance_group_name:
        drchrono_patient["secondary_insurance"]["insurance_group_nam"],
      secondary_insurance_plan_name:
        drchrono_patient["secondary_insurance"]["insurance_plan_name"],
      secondary_insurance_is_subscriber_the_patient:
        drchrono_patient["secondary_insurance"]["is_subscriber_the_patient"],
      secondary_insurance_patient_relationship_to_subscriber:
        drchrono_patient["secondary_insurance"]["patient_relationship_to_subscriber"],
      secondary_insurance_subscriber_state:
        drchrono_patient["secondary_insurance"]["subscriber_state"],
      referring_doctor_first_name: drchrono_patient["referring_doctor"]["first_name"],
      referring_doctor_last_name: drchrono_patient["referring_doctor"]["last_name"],
      referring_doctor_suffix: drchrono_patient["referring_doctor"]["suffix"],
      referring_doctor_npi: drchrono_patient["referring_doctor"]["npi"],
      referring_doctor_email: drchrono_patient["referring_doctor"]["email"],
      referring_doctor_phone: drchrono_patient["referring_doctor"]["phone"]
    }
  end

  # Fetches appointments from Drchrono and inserts them into our database.
  # Has to be queried in date range chunks and by doctor, otherwise requests will timeout.
  def download_appointments do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    all_doctor_ids = Repo.all(from(d in DrchronoDoctor, select: d.uuid))

    Enum.map(all_doctor_ids, fn doctor_id ->
      Enum.map(
        all_date_ranges(),
        &download_range_of_appointments_for_doctor(token, doctor_id, &1)
      )
    end)
  end

  def download_range_of_appointments_for_doctor(token, doctor_id, range, cursor \\ nil) do
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/appointments"

    params =
      if is_nil(cursor),
        do: "?doctor=#{doctor_id}&date_range=#{range}&page_size=20&verbose=true",
        else: ""

    case HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        appointments = Enum.map(data, &normalize_appointment_data(&1))
        IO.inspect(range)
        IO.puts("Doctor ID: #{doctor_id}")
        IO.puts("Downloading #{length(appointments)} appointments")

        Repo.insert_all(DrchronoAppointment, appointments,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor,
          do: download_range_of_appointments_for_doctor(token, doctor_id, range, next_cursor),
          else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_range_of_appointments_for_doctor(token, doctor_id, range, cursor)
    end
  end

  def normalize_appointment_data(drchrono_appointment) do
    %{
      uuid: uuid_to_integer(drchrono_appointment["id"]),
      duration: drchrono_appointment["duration"],
      scheduled_time: cast_to_datetime(drchrono_appointment["scheduled_time"]),
      created_at: cast_to_datetime(drchrono_appointment["created_at"]),
      doctor: drchrono_appointment["doctor"],
      office: drchrono_appointment["office"],
      exam_room: drchrono_appointment["exam_room"],
      profile: drchrono_appointment["profile"],
      reason: drchrono_appointment["reason"],
      status: drchrono_appointment["status"],
      clinical_note_locked: drchrono_appointment["clinical_note"]["locked"],
      clinical_note_pdf: drchrono_appointment["clinical_note"]["pdf"],
      clinical_note_updated_at:
        cast_to_datetime(drchrono_appointment["clinical_note"]["updated_at"]),
      patient: drchrono_appointment["patient"],
      appt_is_break: drchrono_appointment["appt_is_break"],
      recurring_appointment: drchrono_appointment["recurring_appointment"],
      base_recurring_appointment: drchrono_appointment["base_recurring_appointment"],
      is_virtual_base: drchrono_appointment["is_virtual_base"],
      is_walk_in: drchrono_appointment["is_walk_in"],
      allow_overlapping: drchrono_appointment["allow_overlapping"]
    }
  end

  # Fetches doctors from Drchrono and inserts them into our database.
  def download_doctors(cursor \\ nil) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/doctors"

    {:ok, %{body: resp}} = HTTPoison.get(base_uri, [{"Authorization", "Bearer #{token}"}])

    case Jason.decode(resp) do
      {:ok, %{"results" => data, "next" => next_cursor}} ->
        doctors = Enum.map(data, &normalize_doctor_data(&1))
        IO.puts("Downloading #{length(doctors)} doctors")

        Repo.insert_all(DrchronoDoctor, doctors,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor, do: download_doctors(next_cursor), else: IO.puts("Done")

      err ->
        IO.puts("ERROR: ")
        IO.inspect(err)
        :not_found
    end
  end

  def normalize_doctor_data(drchrono_doctor) do
    %{
      uuid: drchrono_doctor["id"],
      first_name: drchrono_doctor["first_name"],
      last_name: drchrono_doctor["last_name"],
      job_title: drchrono_doctor["job_title"],
      specialty: drchrono_doctor["specialty"],
      office_phone: drchrono_doctor["office_phone"],
      profile_picture: drchrono_doctor["profile_picture"],
      suffix: drchrono_doctor["suffix"],
      timezone: drchrono_doctor["timezone"]
    }
  end

  # Fetches offices from Drchrono and inserts them into our database.
  def download_offices(cursor \\ nil) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/offices"

    {:ok, %{body: resp}} = HTTPoison.get(base_uri, [{"Authorization", "Bearer #{token}"}])

    case Jason.decode(resp) do
      {:ok, %{"results" => data, "next" => next_cursor}} ->
        offices = Enum.map(data, &normalize_office_data(&1))
        IO.puts("Downloading #{length(offices)} offices")

        Repo.insert_all(DrchronoOffice, offices,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor, do: download_offices(next_cursor), else: IO.puts("Done")

      err ->
        IO.puts("ERROR: ")
        IO.inspect(err)
        :not_found
    end
  end

  def normalize_office_data(drchrono_office) do
    %{
      uuid: drchrono_office["id"],
      name: drchrono_office["name"],
      address: drchrono_office["address"],
      city: drchrono_office["city"],
      state: drchrono_office["state"],
      zip_code: drchrono_office["zip_code"],
      start_time: drchrono_office["start_time"],
      end_time: drchrono_office["end_time"]
    }
  end

  # Fetches appointment_profiles from Drchrono and inserts them into our database.
  def download_appointment_profiles(cursor \\ nil) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/appointment_profiles"

    {:ok, %{body: resp}} = HTTPoison.get(base_uri, [{"Authorization", "Bearer #{token}"}])
    %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)

    appointment_profiles = Enum.map(data, &normalize_appointment_profile_data(&1))
    IO.puts("Downloading #{length(appointment_profiles)} appointment_profiles")

    Repo.insert_all(DrchronoAppointmentProfile, appointment_profiles,
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: :uuid
    )

    if next_cursor, do: download_appointment_profiles(next_cursor), else: IO.puts("Done")
  end

  def normalize_appointment_profile_data(drchrono_appointment_profile) do
    %{
      uuid: drchrono_appointment_profile["id"],
      color: drchrono_appointment_profile["color"],
      name: drchrono_appointment_profile["name"],
      online_scheduling: drchrono_appointment_profile["online_scheduling"],
      doctor: drchrono_appointment_profile["doctor"],
      duration: drchrono_appointment_profile["duration"],
      reason: drchrono_appointment_profile["reason"],
      sort_order: drchrono_appointment_profile["sort_order"]
    }
  end

  # Fetches procedures from Drchrono and inserts them into our database.
  # Has to be done in date range chunks, otherwise requests will timeout.
  def download_procedures do
    Enum.map(all_date_ranges(), &download_range_of_procedures(&1))
  end

  def download_range_of_procedures(range, cursor \\ nil) do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/procedures"
    params = if is_nil(cursor), do: "?mu_date_range=#{range}", else: ""

    case HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        procedures = Enum.map(data, &normalize_procedure_data(&1))
        IO.puts("Downloading #{length(procedures)} procedures")

        Repo.insert_all(DrchronoProcedure, procedures,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor,
          do: download_range_of_procedures(range, next_cursor),
          else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_range_of_procedures(range, cursor)
    end
  end

  def normalize_procedure_data(drchrono_procedure) do
    %{
      uuid: drchrono_procedure["id"],
      appointment: drchrono_procedure["appointment"],
      doctor: drchrono_procedure["doctor"],
      code: drchrono_procedure["code"],
      procedure_type: drchrono_procedure["procedure_type"],
      adjustment: drchrono_procedure["adjustment"],
      allowed: drchrono_procedure["allowed"],
      balance_ins: drchrono_procedure["balance_ins"],
      balance_pt: drchrono_procedure["balance_pt"],
      balance_total: drchrono_procedure["balance_total"],
      billed: drchrono_procedure["billed"],
      billing_status: drchrono_procedure["billing_status"],
      description: drchrono_procedure["description"],
      expected_reimbursement: drchrono_procedure["expected_reimbursement"],
      ins_total: drchrono_procedure["ins_total"],
      ins1_paid: drchrono_procedure["ins1_paid"],
      ins2_paid: drchrono_procedure["ins2_paid"],
      ins3_paid: drchrono_procedure["ins3_paid"],
      insurance_status: drchrono_procedure["insurance_status"],
      paid_total: string_to_float(drchrono_procedure["paid_total"]),
      patient: drchrono_procedure["patient"],
      posted_date: cast_to_datetime(drchrono_procedure["posted_date"]),
      price: drchrono_procedure["price"],
      pt_paid: drchrono_procedure["pt_paid"],
      service_date: cast_to_datetime(drchrono_procedure["service_date"])
    }
  end

  # Fetches line_items from Drchrono and inserts them into our database.
  # Has to be done by doctor, otherwise requests will timeout.
  def download_line_items do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    all_doctor_ids = Repo.all(from(d in DrchronoDoctor, select: d.uuid))
    Enum.map(all_doctor_ids, &download_line_items_for_doctor(token, &1))
  end

  def download_line_items_for_doctor(token, doctor_id, cursor \\ nil) do
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/line_items"
    params = if is_nil(cursor), do: "?doctor=#{doctor_id}", else: ""

    case HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        line_items = Enum.map(data, &normalize_line_item_data(&1))
        IO.puts("Downloading #{length(line_items)} line_items")

        Repo.insert_all(DrchronoLineItem, line_items,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor,
          do: download_line_items_for_doctor(token, doctor_id, next_cursor),
          else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_line_items_for_doctor(token, doctor_id, cursor)
    end
  end

  def normalize_line_item_data(drchrono_line_item) do
    %{
      uuid: drchrono_line_item["id"],
      appointment: drchrono_line_item["appointment"],
      code: drchrono_line_item["code"],
      procedure_type: drchrono_line_item["procedure_type"],
      adjustment: string_to_float(drchrono_line_item["adjustment"]),
      allowed: string_to_float(drchrono_line_item["allowed"]),
      balance_ins: string_to_float(drchrono_line_item["balance_ins"]),
      balance_pt: string_to_float(drchrono_line_item["balance_pt"]),
      balance_total: string_to_float(drchrono_line_item["balance_total"]),
      billed: string_to_float(drchrono_line_item["billed"]),
      billing_status: drchrono_line_item["billing_status"],
      denied_flag: drchrono_line_item["denied_flag"],
      description: drchrono_line_item["description"],
      doctor: drchrono_line_item["doctor"],
      expected_reimbursement: string_to_float(drchrono_line_item["expected_reimbursement"]),
      ins_total: string_to_float(drchrono_line_item["ins_total"]),
      ins1_paid: string_to_float(drchrono_line_item["ins1_paid"]),
      ins2_paid: string_to_float(drchrono_line_item["ins2_paid"]),
      ins3_paid: string_to_float(drchrono_line_item["ins3_paid"]),
      insurance_status: drchrono_line_item["insurance_status"],
      paid_total: string_to_float(drchrono_line_item["paid_total"]),
      patient: drchrono_line_item["patient"],
      posted_date: cast_to_datetime(drchrono_line_item["posted_date"]),
      price: string_to_float(drchrono_line_item["price"]),
      pt_paid: string_to_float(drchrono_line_item["pt_paid"]),
      quantity: string_to_float(drchrono_line_item["quantity"]),
      units: drchrono_line_item["units"],
      service_date: cast_to_datetime(drchrono_line_item["service_date"])
    }
  end

  # Fetches problems from Drchrono and inserts them into our database.
  def download_problems do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    all_doctor_ids = Repo.all(from(d in DrchronoDoctor, select: d.uuid))
    Enum.map(all_doctor_ids, &download_problems_for_doctor(token, &1))
  end

  def download_problems_for_doctor(token, doctor_id, cursor \\ nil) do
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/problems"
    params = if is_nil(cursor), do: "?doctor=#{doctor_id}", else: ""

    case HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        problems = Enum.map(data, &normalize_problem_data(&1))
        IO.puts("Downloading #{length(problems)} problems")

        Repo.insert_all(DrchronoProblem, problems,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor,
          do: download_problems_for_doctor(token, doctor_id, next_cursor),
          else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_problems_for_doctor(token, doctor_id, cursor)
    end
  end

  def normalize_problem_data(drchrono_problem) do
    %{
      uuid: drchrono_problem["id"],
      doctor: drchrono_problem["doctor"],
      patient: drchrono_problem["patient"],
      date_changed: cast_to_datetime(drchrono_problem["date_changed"]),
      date_diagnosis: cast_to_datetime(drchrono_problem["date_diagnosis"]),
      date_onset: cast_to_datetime(drchrono_problem["date_onset"]),
      description: drchrono_problem["description"],
      icd_code: drchrono_problem["icd_code"],
      info_url: drchrono_problem["info_url"],
      name: drchrono_problem["name"],
      notes: drchrono_problem["notes"],
      snomed_ct_code: drchrono_problem["snomed_ct_code"],
      status: drchrono_problem["status"]
    }
  end

  # Fetches medications from Drchrono and inserts them into our database.
  # Has to be done by doctor, otherwise requests will timeout.
  def download_medications do
    token = MindfulWeb.Services.TokensCache.get_drchrono_token()
    all_doctor_ids = Repo.all(from(d in DrchronoDoctor, select: d.uuid))
    Enum.map(all_doctor_ids, &download_medications_for_doctor(token, &1))
  end

  def download_medications_for_doctor(token, doctor_id, cursor \\ nil) do
    base_uri = if cursor, do: cursor, else: "https://drchrono.com/api/medications"
    params = if is_nil(cursor), do: "?doctor=#{doctor_id}", else: ""

    case HTTPoison.get(base_uri <> params, [{"Authorization", "Bearer #{token}"}]) do
      {:ok, %{body: resp}} ->
        %{"results" => data, "next" => next_cursor} = Jason.decode!(resp)
        medications = Enum.map(data, &normalize_medication_data(&1))
        IO.puts("Downloading #{length(medications)} medications")

        Repo.insert_all(DrchronoMedication, medications,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if next_cursor,
          do: download_medications_for_doctor(token, doctor_id, next_cursor),
          else: IO.puts("Done")

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_medications_for_doctor(token, doctor_id, cursor)
    end
  end

  def normalize_medication_data(drchrono_medication) do
    %{
      uuid: drchrono_medication["id"],
      doctor: drchrono_medication["doctor"],
      patient: drchrono_medication["patient"],
      appointment: drchrono_medication["appointment"],
      date_prescribed: cast_to_datetime(drchrono_medication["date_prescribed"]),
      date_started_taking: cast_to_datetime(drchrono_medication["date_started_taking"]),
      date_stopped_taking: cast_to_datetime(drchrono_medication["date_stopped_taking"]),
      daw: drchrono_medication["daw"],
      dispense_quantity: string_to_float(drchrono_medication["dispense_quantity"]),
      dosage_quantity: drchrono_medication["dosage_quantity"],
      dosage_unit: drchrono_medication["dosage_unit"],
      frequency: drchrono_medication["frequency"],
      indication: drchrono_medication["indication"],
      name: drchrono_medication["name"],
      ndc: drchrono_medication["ndc"],
      notes: drchrono_medication["notes"],
      number_refills: drchrono_medication["number_refills"],
      order_status: drchrono_medication["order_status"],
      pharmacy_note: drchrono_medication["pharmacy_note"],
      prn: drchrono_medication["prn"],
      route: drchrono_medication["route"],
      rxnorm: drchrono_medication["rxnorm"],
      signature_note: drchrono_medication["signature_note"],
      status: drchrono_medication["status"]
    }
  end

  # date ranges broken down into chunks that don't cause timeouts (discovered by manually running each one)
  defp all_date_ranges do
    [
      "2019-02-01%2f2020-01-01",
      "2020-01-02%2f2020-04-01",
      "2020-04-02%2f2020-05-01",
      "2020-05-02%2f2020-07-01",
      "2020-07-02%2f2020-09-01",
      "2020-09-02%2f2020-11-01",
      "2020-11-02%2f2021-01-01",
      "2021-01-02%2f2021-03-01",
      "2021-03-02%2f2021-04-01",
      "2021-04-02%2f2021-05-01",
      "2021-05-02%2f2021-06-01",
      "2021-06-02%2f2021-07-01",
      "2021-07-02%2f2021-08-01",
      "2021-08-02%2f2021-09-01",
      "2021-09-02%2f2021-10-01",
      "2021-10-02%2f2021-11-01",
      "2021-11-02%2f2021-12-01",
      "2021-12-02%2f2022-01-01",
      "2022-01-02%2f2022-02-01",
      "2022-02-02%2f2022-03-01",
      "2022-03-02%2f2022-04-01",
      "2022-04-02%2f2022-05-01",
      "2022-05-02%2f2022-06-01"
    ]
  end

  defp uuid_to_integer(nil), do: nil

  defp uuid_to_integer(appt_id), do: appt_id |> String.replace("_", "") |> String.to_integer()

  defp cast_to_datetime(nil), do: nil

  defp cast_to_datetime(timestamp) do
    # example format from drchrono API: "2019-05-22T13:00:00"
    case Timex.parse(timestamp, "%Y-%m-%dT%H:%M:%S", :strftime) do
      {:ok, time} ->
        Timex.to_datetime(time)

      {:error, _} ->
        # Try parsing for only day. Example format from drchrono API for date: "1979-06-04"
        Timex.to_datetime(Timex.parse!(timestamp, "%Y-%m-%d", :strftime))
    end
  end

  defp string_to_float(nil), do: nil
  defp string_to_float(""), do: nil

  defp string_to_float(string) do
    case Float.parse(string) do
      {float, _} -> float
      :error -> nil
    end
  end
end
