defmodule Mindful.Appointments.AppointmentTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.OfficeHelper
  import Mindful.Test.Support.ProviderHelper
  import Mindful.Test.Support.UserHelper

  alias Mindful.Appointments.Appointment

  setup do
    office = given_office()
    provider = given_provider(%{office: office})
    user = given_user()

    {:ok, user: user, provider: provider, office: office}
  end

  describe "changeset/2" do
    test "fails with invalid attrs", %{provider: provider, office: office} do
      attrs = %{
        duration: 30,
        time_zone: "America/Chicago",
        office_id: office.id,
        provider_id: provider.id,
        drchrono_appointment_id: "invalid",
        type: "type"
      }

      assert %{valid?: false} = changeset = Appointment.changeset(%Appointment{}, attrs)

      assert %{
               start_at: ["can't be blank"],
               user_id: ["can't be blank"],
               type: ["is invalid"],
               drchrono_appointment_id: ["is invalid"]
             } = errors_on(changeset)
    end

    test "calculates end_at", %{user: user, provider: provider, office: office} do
      attrs = valid_attrs()

      attrs =
        Map.merge(attrs, %{
          office_id: office.id,
          provider_id: provider.id,
          user_id: user.id
        })

      assert %{valid?: true, changes: %{end_at: end_at}} =
               Appointment.changeset(%Appointment{}, attrs)

      assert :gt == DateTime.compare(end_at, attrs.start_at)
    end

    test "calculate duration", %{
      user: user,
      provider: provider,
      office: office
    } do
      attrs = %{
        start_at: DateTime.utc_now(),
        duration: nil,
        time_zone: "America/Chicago",
        office_id: office.id,
        provider_id: provider.id,
        user_id: user.id,
        drchrono_appointment_id: 123,
        type: "default"
      }

      assert %{valid?: true, changes: %{duration: duration}} =
               Appointment.changeset(%Appointment{}, attrs)

      assert 30 == duration
    end

    test "duration overrides type when set", %{
      user: user,
      provider: provider,
      office: office
    } do
      attrs = valid_attrs()

      attrs =
        Map.merge(attrs, %{
          office_id: office.id,
          provider_id: provider.id,
          user_id: user.id,
          duration: 120
        })

      assert %{valid?: true, changes: %{duration: duration}} =
               Appointment.changeset(%Appointment{}, attrs)

      assert 120 == duration
    end
  end

  ## Private Functions

  defp valid_attrs do
    %{
      start_at: DateTime.utc_now(),
      duration: 30,
      time_zone: "America/Chicago",
      drchrono_appointment_id: 123,
      type: "default"
    }
  end
end
