defmodule Mindful.ChronoSchemas.DrchronoAppointment do
  @moduledoc """
  This is the schema for an appointment from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_appointments" do
    field :uuid, :integer
    field :duration, :integer
    field :scheduled_time, :utc_datetime
    field :created_at, :utc_datetime
    field :doctor, :integer
    field :office, :integer
    field :exam_room, :integer
    field :profile, :integer
    field :reason, :string
    field :status, :string
    field :clinical_note_locked, :boolean
    field :clinical_note_pdf, :string
    field :clinical_note_updated_at, :utc_datetime
    field :patient, :integer
    field :appt_is_break, :boolean
    field :recurring_appointment, :boolean
    field :base_recurring_appointment, :integer
    field :is_virtual_base, :boolean
    field :is_walk_in, :boolean
    field :allow_overlapping, :boolean
  end
end
