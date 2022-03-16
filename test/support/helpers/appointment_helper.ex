defmodule Mindful.Test.Support.AppointmentHelper do
  @moduledoc """
  Provides helpers for tests related to Appointments.
  """
  alias Mindful.Appointments.Appointment
  alias Mindful.Factory

  @spec given_appointment(map) :: Appointment.t()
  def given_appointment(attrs \\ %{}) do
    appointment_attrs =
      attrs
      |> fetch_keys()

    Factory.insert(:appointment, appointment_attrs)
  end

  def given_future_appointment(attrs \\ %{}) do
    start_at = extract_time(attrs, :start_at)
    duration = Map.get(attrs, :duration, 30)

    attrs =
      set_attrs(attrs, %{
        start_at: start_at,
        duration: duration,
        end_at: DateTime.add(start_at, duration * 60, :second)
      })

    Factory.insert(:appointment, attrs)
  end

  def given_confirmed_appointment(attrs \\ %{}) do
    attrs =
      set_attrs(attrs, %{
        confirmed_at: extract_time(attrs, :confirmed_at)
      })

    Factory.insert(:appointment, attrs)
  end

  def given_canceled_appointment(attrs \\ %{}) do
    attrs =
      set_attrs(attrs, %{
        canceled_at: extract_time(attrs, :canceled_at)
      })

    Factory.insert(:appointment, attrs)
  end

  ## Private Functions

  defp fetch_keys(attrs) do
    appointment_keys = Map.keys(%Appointment{})

    Map.take(attrs, appointment_keys)
  end

  defp extract_time(map, key), do: Map.get_lazy(map, key, &NaiveDateTime.utc_now/0)

  defp set_attrs(attrs, new_attrs) do
    attrs
    |> fetch_keys()
    |> Map.merge(new_attrs)
  end
end
