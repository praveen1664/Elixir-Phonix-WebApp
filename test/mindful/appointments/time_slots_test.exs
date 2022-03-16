defmodule Mindful.TimeSlotsTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.AppointmentHelper
  import Mindful.Test.Support.OfficeHelper
  import Mindful.Test.Support.ProviderHelper
  import Mindful.Test.Support.UserHelper

  alias Mindful.Appointments.TimeSlots

  @config Application.compile_env!(:mindful, TimeSlots)
  @default_time_zone Keyword.fetch!(@config, :time_zone)

  @start_at ~U[2022-01-01 13:00:00.000000Z]

  setup do
    office = given_office()
    provider = given_provider(%{office: office})
    user = given_user()

    appointment =
      given_appointment(%{
        start_at: @start_at,
        user_id: user.id,
        duration: 120,
        provider_id: provider.id,
        office_id: office.id
      })

    {:ok, appointment: appointment, user: user, provider: provider, office: office}
  end

  describe "fetch_time/2" do
    test "returns canceled_at time from params" do
      assert canceled_at = TimeSlots.fetch_time(valid_attrs(), :canceled_at)
      assert Timex.is_valid?(canceled_at)
    end

    test "returns confirmed_at  time from params" do
      assert confirmed_at = TimeSlots.fetch_time(valid_attrs(), :confirmed_at)
      assert Timex.is_valid?(confirmed_at)
    end
  end

  describe "extract_duration/1" do
    test "returns an appointment duration from params" do
      attrs = Map.put(valid_attrs(), :type, "evaluation")
      assert 40 = TimeSlots.extract_duration(attrs)
    end

    test "returns default duration if the appointment has no duration" do
      assert 30 = TimeSlots.extract_duration(valid_attrs())
    end
  end

  describe "extract_time_zone/1" do
    test "returns a valid default timezone" do
      assert timezone = TimeSlots.extract_time_zone(valid_attrs())
      assert timezone == @default_time_zone
    end

    test "returns the given timezone in attrs" do
      attrs = Map.put(valid_attrs(), :time_zone, "America/Chicago")
      assert timezone = TimeSlots.extract_time_zone(attrs)
      assert timezone == "America/Chicago"
    end
  end

  describe "is_different_datetime/2" do
    test "returns false if appointment start_at date is same as given start_at", %{
      appointment: appointment
    } do
      assert false == TimeSlots.is_different_datetime?(appointment.start_at, @start_at)
    end

    test "returns true if appointment start_at date is different from the given start_at", %{
      appointment: appointment
    } do
      assert true == TimeSlots.is_different_datetime?(appointment.start_at, DateTime.utc_now())
    end
  end

  defp valid_attrs do
    %{
      start_at: DateTime.utc_now(),
      drchrono_appointment_id: 123,
      type: "default"
    }
  end
end
