defmodule Mindful.Factories.Appointment do
  @moduledoc false

  alias Mindful.Appointments.Appointment

  defmacro __using__(_opts) do
    quote do
      def appointment_factory do
        %Appointment{
          start_at: ~U[2022-01-01 13:00:00.000000Z],
          end_at: ~U[2022-01-01 13:30:00.000000Z],
          duration: 30,
          time_zone: "America/New_York",
          type: "default",
          drchrono_appointment_id: System.unique_integer([:positive])
        }
      end
    end
  end
end
