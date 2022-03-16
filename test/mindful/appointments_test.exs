defmodule Mindful.AppointmentsTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.AppointmentHelper
  import Mindful.Test.Support.OfficeHelper
  import Mindful.Test.Support.ProviderHelper
  import Mindful.Test.Support.UserHelper

  alias Mindful.Appointments
  alias Mindful.Appointments.Appointment
  alias Mindful.Appointments.TimeSlots

  @config Application.compile_env!(:mindful, TimeSlots)
  @default_day_start Keyword.fetch!(@config, :day_start)

  setup do
    office = given_office()
    provider = given_provider(%{office: office})
    user = given_user()

    appointment =
      given_appointment(%{user_id: user.id, provider_id: provider.id, office_id: office.id})

    {:ok, appointment: appointment, user: user, provider: provider, office: office}
  end

  describe "get/1" do
    test "successfully fetches an existent appointment", %{appointment: appt} do
      assert {:ok, %Appointment{} = appointment} = Appointments.get(appt.id)
      assert appointment == appt
    end

    test "fails if not existent" do
      assert {:error, :not_found} = Appointments.get(123)
    end
  end

  describe "create/1" do
    test "successfully creates a new appointment for today", %{
      user: user,
      provider: provider,
      office: office
    } do
      attrs = valid_attrs(user, provider, office)

      assert {:ok, %Appointment{} = appointment} = Appointments.create(attrs)

      assert appointment.start_at ==
               DateTime.add(appointment.end_at, -attrs.duration * 60, :second)
    end

    test "successfully creates a new appointment for future date", %{
      user: user,
      provider: provider,
      office: office
    } do
      today = Date.utc_today()

      {:ok, future_date} =
        today
        |> Date.add(6)
        |> DateTime.new(~T[15:00:00])

      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{start_at: future_date})

      assert {:ok, appointment} = Appointments.create(attrs)
      assert appointment.start_at.day == future_date.day
      assert appointment.start_at.month == future_date.month
    end

    test "fails with start_at on invalid hours range", %{
      user: user,
      provider: provider,
      office: office
    } do
      {:ok, invalid_time} = DateTime.new(Date.utc_today(), ~T[06:00:00])

      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{start_at: invalid_time})

      {:error, :invalid_time_slot} = Appointments.create(attrs)
    end

    test "fails with invalid start_at", %{user: user, provider: provider, office: office} do
      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{start_at: "invalid"})

      {:error, :invalid_time_slot} = Appointments.create(attrs)
    end

    test "fails if Dr Chrono ID is aleady existent", %{
      appointment: appt,
      user: user,
      provider: provider,
      office: office
    } do
      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{
          drchrono_appointment_id: appt.drchrono_appointment_id
        })

      assert {:error, changeset} = Appointments.create(attrs)
      assert %{drchrono_appointment_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "fails if references don't exist", %{user: user, provider: provider, office: office} do
      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{user_id: 123_123_123_123_123})

      assert {:error, changeset} = Appointments.create(attrs)
      assert %{user_id: ["does not exist"]} = errors_on(changeset)
    end

    test "fails if desired time slot is already taken", %{
      user: user,
      provider: provider,
      office: office,
      appointment: appt
    } do
      attrs =
        user
        |> valid_attrs(provider, office)
        |> Map.merge(%{start_at: appt.start_at})

      {:error, :invalid_time_slot} = Appointments.create(attrs)
    end
  end

  describe "update/1" do
    test "updates an appointment with UTC start_at", %{appointment: appt} do
      {:ok, start_at} = DateTime.new(Date.utc_today(), ~T[17:00:00.000000])

      assert {:ok, appointment} = Appointments.update(appt, %{start_at: start_at})
      assert :lt = DateTime.compare(appt.start_at, appointment.start_at)
      assert :eq = DateTime.compare(appointment.start_at, start_at)
      assert :gt = DateTime.compare(appointment.end_at, start_at)
    end

    test "updates an appointment with time zone start_at", %{appointment: appt} do
      {:ok, start_at} =
        Date.utc_today()
        |> DateTime.new!(~T[17:00:00])
        |> DateTime.shift_zone("America/New_York")

      # Account for daylight savings
      assert start_at.hour == 12 || start_at.hour == 13

      assert {:ok, appointment} = Appointments.update(appt, %{start_at: start_at})
      assert :eq = DateTime.compare(appointment.start_at, start_at)
      assert :gt = DateTime.compare(appointment.end_at, start_at)
    end

    test "successfully updates an appointment with same start_at", %{appointment: appt} do
      start_at = DateTime.shift_zone!(appt.start_at, "America/Manaus")

      attrs = %{
        start_at: start_at,
        notes: "123 test"
      }

      assert start_at.hour == 9

      assert {:ok, appointment} = Appointments.update(appt, attrs)
      assert :eq == DateTime.compare(appt.start_at, start_at)
      assert :eq == DateTime.compare(appointment.start_at, appt.start_at)
      assert appointment.notes == "123 test"
    end

    test "fails with invalid start_at time slot", %{appointment: appt} do
      now = DateTime.utc_now()

      assert {:error, :invalid_time_slot} = Appointments.update(appt, %{start_at: now})
    end

    test "updates appointment type", %{appointment: appointment} do
      # therapy => 30
      attrs = %{type: "therapy"}

      assert {:ok, %Appointment{duration: duration}} = Appointments.update(appointment, attrs)

      assert 30 == duration
    end

    test "fails with invalid attrs", %{appointment: appt} do
      assert {:error, :invalid_time_slot} = Appointments.update(appt, %{start_at: "invalid"})
    end
  end

  describe "get_provider_availability/2" do
    test "fetches a provider therapy slots", %{provider: provider} do
      [slot_1 | rest] =
        slots = Appointments.get_provider_availability(provider.id, %{type: "therapy"})

      [slot_2 | _] = rest

      assert length(slots) == 22
      assert slot_1.hour == @default_day_start
      assert slot_1.minute == 0
      assert slot_2.hour == @default_day_start
      assert slot_2.minute == 30
    end

    test "fetches a provider evaluation slots", %{provider: provider} do
      [slot_1 | rest] =
        slots = Appointments.get_provider_availability(provider.id, %{type: "evaluation"})

      [slot_2 | _] = rest

      assert length(slots) == 16
      assert slot_1.hour == @default_day_start
      assert slot_1.minute == 0
      assert slot_2.hour == @default_day_start
      assert slot_2.minute == 40
    end

    test "filters already occupied slots for therapy", %{
      user: user,
      provider: provider,
      office: office,
      appointment: appt
    } do
      attrs = %{
        type: "therapy",
        date: DateTime.to_date(appt.start_at)
      }

      add_extra_appointments(%{user: user, provider: provider, office: office}, appt, 6)

      [slot_1 | _] = slots = Appointments.get_provider_availability(provider.id, attrs)

      assert length(slots) == 15
      assert slot_1.hour == 11
      assert slot_1.minute == 30
    end

    test "filters already occupied slots for evaluation", %{
      user: user,
      provider: provider,
      office: office,
      appointment: appt
    } do
      attrs = %{
        type: "evaluation",
        date: DateTime.to_date(appt.start_at)
      }

      add_extra_appointments(%{user: user, provider: provider, office: office}, appt)

      [slot_1 | _] = slots = Appointments.get_provider_availability(provider.id, attrs)

      assert length(slots) == 13
      assert slot_1.hour == 10
      assert slot_1.minute == 00
    end

    test "fetches slots for given date", %{provider: provider} do
      today = Date.utc_today()
      date = Timex.shift(today, days: -3)

      assert :gt = Date.compare(today, date)

      attrs = %{
        type: "therapy",
        date: date
      }

      [slot | _] = Appointments.get_provider_availability(provider.id, attrs)

      assert slot.day == date.day
      assert slot.month == date.month
      assert slot.year == date.year
    end
  end

  describe "confirm/1" do
    test "successfully updates an appointment", %{appointment: appt} do
      refute appt.confirmed_at
      assert {:ok, appointment} = Appointments.confirm(appt)
      assert appointment.confirmed_at
    end

    test "successfully updates an appointment with arbitrary time", %{appointment: appt} do
      confirmed_at = ~U[2022-01-01 12:30:00.000000Z]

      refute appt.confirmed_at

      assert {:ok, appointment} = Appointments.confirm(appt, %{confirmed_at: confirmed_at})
      assert appointment.confirmed_at == confirmed_at
    end
  end

  describe "cancel/1" do
    test "successfully updates an appointment", %{appointment: appt} do
      refute appt.canceled_at
      assert {:ok, appointment} = Appointments.cancel(appt)
      assert appointment.canceled_at
    end

    test "successfully updates an appointment with arbitrary time", %{appointment: appt} do
      canceled_at = ~U[2022-01-01 12:30:00.000000Z]

      refute appt.canceled_at

      assert {:ok, appointment} = Appointments.cancel(appt, %{canceled_at: canceled_at})
      assert appointment.canceled_at == canceled_at
    end
  end

  ## Helpers

  defp valid_attrs(user, provider, office) do
    {:ok, start_at} = DateTime.new(Date.utc_today(), ~T[17:00:00])

    %{
      start_at: start_at,
      duration: 30,
      time_zone: "America/New_York",
      type: "default",
      drchrono_appointment_id: 763_049_663_434,
      user_id: user.id,
      provider_id: provider.id,
      office_id: office.id
    }
  end

  defp add_extra_appointments(%{user: user, provider: provider, office: office}, appt, count \\ 3) do
    Enum.reduce(1..count, {[], appt.duration}, fn _, {appts, duration} ->
      attrs = %{
        start_at: Timex.shift(appt.start_at, minutes: duration),
        end_at: Timex.shift(appt.end_at, minutes: duration),
        duration: appt.duration,
        user_id: user.id,
        provider_id: provider.id,
        office_id: office.id
      }

      appt = given_appointment(attrs)

      {[appt | appts], duration + appt.duration}
    end)
  end
end
