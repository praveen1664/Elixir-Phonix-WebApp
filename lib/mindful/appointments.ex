defmodule Mindful.Appointments do
  @moduledoc """
  The appointments context
  """
  use Mindful, :context

  import Ecto.Query, only: [where: 3]

  alias Mindful.Appointments.Appointment
  alias MindfulWeb.DrchronoAdapter

  alias Mindful.Appointments.TimeSlots

  @doc """
  Fetches an appointment by ID
  """
  @spec get(integer()) :: {:ok, Appointment.t()} | {:error, :not_found}
  def get(appt_id) do
    case Repo.get(Appointment, appt_id) do
      nil -> {:error, :not_found}
      appointment -> {:ok, appointment}
    end
  end

  @doc """
  Creates a new appointment
  """
  @spec create(map()) ::
          {:ok, Appointment.t()} | {:error, Changeset.t()} | {:error, :invalid_time_slot}
  def create(%{provider_id: provider_id, start_at: start_at} = attrs) do
    with :ok <- validate_availability(provider_id, start_at, attrs),
         changeset <- Appointment.changeset(%Appointment{}, attrs) do
      Repo.insert(changeset)
    end
  end

  @doc """
  Updates an appointment
  """
  @spec update(Appointment.t(), map()) ::
          {:ok, Appointment.t()} | {:error, Changeset.t()} | {:error, :invalid_time_slot}
  def update(%Appointment{} = appointment, %{start_at: start_at} = attrs) do
    if TimeSlots.is_different_datetime?(appointment.start_at, start_at) do
      with :ok <- validate_availability(appointment.provider_id, start_at, attrs),
           changeset <- Appointment.changeset(appointment, attrs) do
        Repo.update(changeset)
      end
    else
      update(appointment, Map.drop(attrs, [:start_at]))
    end
  end

  def update(%Appointment{} = appointment, attrs) do
    appointment
    |> Appointment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Calculates a provider's available time slots for given date and appointment type.
  """
  @spec get_provider_availability(integer(), map()) :: [DateTime.t()]
  def get_provider_availability(provider_id, params \\ %{}) do
    date = Map.get(params, :date, Date.utc_today())
    time_zone = TimeSlots.extract_time_zone(params)
    duration = TimeSlots.extract_duration(params)

    appointments = do_get_provider_appointments(provider_id, date)

    TimeSlots.calculate_time_slots(date, time_zone, duration, appointments)
  end

  @doc """
  Confirms an appointment
  """
  @spec confirm(Appointment.t(), map()) :: {:ok, Appointment.t()} | {:error, Changeset.t()}
  def confirm(%Appointment{} = appointment, attrs \\ %{}) do
    confirmed_at = TimeSlots.fetch_time(attrs, :confirmed_at)

    appointment
    |> Appointment.changeset(%{confirmed_at: confirmed_at})
    |> Repo.update()
  end

  @doc """
  Cancels an appointment
  """
  @spec cancel(Appointment.t(), map()) :: {:ok, Appointment.t()} | {:error, Changeset.t()}
  def cancel(%Appointment{} = appointment, attrs \\ %{}) do
    canceled_at = TimeSlots.fetch_time(attrs, :canceled_at)

    appointment
    |> Appointment.changeset(%{canceled_at: canceled_at})
    |> Repo.update()
  end

  defp validate_availability(provider_id, start_at, attrs) do
    with %Date{} = date <- Timex.to_date(start_at),
         current_slots <- get_provider_availability(provider_id, Map.put(attrs, :date, date)),
         {:ok, _slot} <- TimeSlots.validate_slot(current_slots, attrs) do
      :ok
    else
      {:error, :invalid_date} ->
        {:error, :invalid_time_slot}

      error ->
        error
    end
  end

  # TODO: refactor once DrChrono schemas are available
  defp do_get_provider_appointments(provider_id, date) do
    local_appointments =
      Appointment
      |> where([a], a.provider_id == ^provider_id)
      |> where([a], fragment("?::date", a.start_at) == ^date)
      |> Repo.all()

    # Only fetch from Dr Chrono when none is found locally.
    with [] <- local_appointments,
         {:ok, appointments} <-
           DrchronoAdapter.fetch_appointments_for_provider(provider_id, %{date: date}),
         parsed_appointments <- parse_drchrono_appointments(appointments) do
      # NOTE: maybe insert parsed_appointments here?
      parsed_appointments
    else
      _ ->
        local_appointments
    end
  end

  # TODO: move this helpers to DrChrono client
  defp parse_drchrono_appointments(appointments) when is_list(appointments) do
    Enum.map(appointments, &parse_drchrono_appointment/1)
  end

  defp parse_drchrono_appointment(appt) do
    start_at = parse_drchrono_time(appt["scheduled_time"])
    duration = appt["duration"]
    end_at = calc_end_at(start_at, duration)

    %{
      drchrono_appointment_id: appt["id"],
      provider_id: appt["doctor"],
      office_id: appt["office"],
      user_id: appt["patient"],
      duration: duration,
      notes: appt["notes"],
      virtual: appt["is_virtual_base"],
      recurring: appt["recurring_appointment"],
      start_at: start_at,
      end_at: end_at,
      status: appt["status"],
      inserted_at: parse_drchrono_time(appt["created_at"]),
      updated_at: parse_drchrono_time(appt["updated_at"])
    }
  end

  defp parse_drchrono_time(nil), do: nil

  defp parse_drchrono_time(time) do
    case DateTime.from_iso8601(time) do
      {:ok, datetime, _} -> DateTime.truncate(datetime, :second)
      _ -> nil
    end
  end

  defp calc_end_at(nil, _duration), do: nil
  defp calc_end_at(start_at, nil), do: start_at
  defp calc_end_at(start_at, duration), do: DateTime.add(start_at, duration * 60, :second)
end
