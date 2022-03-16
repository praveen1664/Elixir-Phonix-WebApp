defmodule Mindful.Appointments.TimeSlots do
  @moduledoc """
  Calculates a provider's available time slots for given date and appointment type.
  """
  alias Mindful.Appointments.Appointment

  @config Application.compile_env!(:mindful, __MODULE__)
  @default_time_zone Keyword.fetch!(@config, :time_zone)
  @default_day_start Keyword.fetch!(@config, :day_start)
  @default_day_end Keyword.fetch!(@config, :day_end)

  # TODO: filter invalid week days
  def fetch_time(attrs, key), do: Map.get_lazy(attrs, key, &DateTime.utc_now/0)

  def extract_duration(%{type: type}) do
    appointments = Appointment.appointments()

    Map.fetch!(appointments, type)
  end

  def extract_duration(_), do: Appointment.default_duration()

  def extract_time_zone(attrs) do
    Map.get(attrs, :time_zone, @default_time_zone)
  end

  def is_different_datetime?(start_1, start_2) do
    case DateTime.compare(start_1, start_2) do
      :eq -> false
      _ -> true
    end
  rescue
    _ -> true
  end

  def validate_slot(slots, %{start_at: start_at} = attrs) do
    time_zone = extract_time_zone(attrs)

    desired_slot =
      start_at
      |> Timex.to_datetime(time_zone)
      |> DateTime.truncate(:second)

    slots
    |> Enum.find(fn slot -> slot == desired_slot end)
    |> case do
      nil -> {:error, :invalid_time_slot}
      slot -> {:ok, slot}
    end
  end

  def calculate_time_slots(date, time_zone, duration, appointments) do
    from =
      date
      |> Timex.to_datetime(time_zone)
      |> Timex.set(hour: @default_day_start)

    until = Timex.set(from, hour: @default_day_end)

    from
    |> Stream.iterate(&DateTime.add(&1, duration * 60, :second))
    |> Stream.take_while(&(DateTime.diff(until, &1) > 0))
    |> Stream.take_while(&filter_last_slot(&1, until, duration))
    |> Stream.reject(&reject_overlaps(&1, appointments, duration))
    |> Enum.to_list()
  end

  # Filters slots so that last one's total duration is inside the
  # day's total working hours range
  defp filter_last_slot(slot, until, duration) do
    slot
    |> DateTime.add(duration * 60, :second)
    |> DateTime.diff(until)
    |> case do
      diff when diff > 0 -> false
      _ -> true
    end
  end

  # Filters slots so that none overlaps with current appointments
  defp reject_overlaps(slot, appointments, duration) do
    next_time_slot = DateTime.add(slot, duration * 60, :second)

    Enum.any?(appointments, fn appt ->
      if DateTime.compare(appt.start_at, slot) == :lt do
        DateTime.compare(appt.end_at, slot) == :gt
      else
        DateTime.compare(appt.start_at, next_time_slot) == :lt
      end
    end)
  end
end
