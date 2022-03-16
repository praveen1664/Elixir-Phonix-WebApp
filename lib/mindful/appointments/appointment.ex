defmodule Mindful.Appointments.Appointment do
  @moduledoc """
  The Appointment schema
  """
  use Mindful, :schema

  alias Mindful.Accounts.User
  alias Mindful.Clinicians.Provider
  alias Mindful.Locations.Office

  @default_duration 30
  @appointments %{
    "default" => @default_duration,
    "therapy" => @default_duration,
    "evaluation" => 40
  }
  @appointment_types Map.keys(@appointments)

  schema "appointments" do
    field :type, :string, null: false
    field :recurring, :boolean, null: false, default: false
    field :virtual, :boolean, null: false, default: false
    field :start_at, :utc_datetime_usec, null: false
    field :end_at, :utc_datetime_usec, null: false
    field :time_zone, :string, null: false
    field :duration, :integer, null: false
    field :status, :string
    field :url, :string
    field :confirmed_at, :utc_datetime_usec
    field :canceled_at, :utc_datetime_usec
    field :notes, :string
    field :drchrono_appointment_id, :integer, null: false

    belongs_to(:user, User)
    belongs_to(:provider, Provider)
    belongs_to(:office, Office)

    timestamps()
  end

  @fields ~w(status url confirmed_at canceled_at notes duration)a
  @required_fields ~w(type recurring start_at time_zone drchrono_appointment_id user_id provider_id office_id)a

  @spec appointments :: map()
  def appointments, do: @appointments

  @spec default_duration :: integer()
  def default_duration, do: @default_duration

  @doc false
  def changeset(%__MODULE__{} = appointment, attrs) do
    appointment
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @appointment_types)
    |> calculate_duration()
    |> calculate_end_at()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:provider_id)
    |> foreign_key_constraint(:office_id)
    |> unique_constraint(:drchrono_appointment_id)
  end

  ## Private Functions

  defp calculate_duration(%{changes: %{duration: _}} = changeset), do: changeset

  defp calculate_duration(%{changes: %{type: type}} = changeset) do
    duration = Map.get(@appointments, type, @default_duration)

    put_change(changeset, :duration, duration)
  end

  defp calculate_duration(changeset), do: changeset

  defp calculate_end_at(%{changes: %{start_at: start_at}} = changeset) do
    duration_secs =
      changeset
      |> fetch_field!(:duration)
      |> Kernel.*(60)

    end_at = DateTime.add(start_at, duration_secs, :second)

    put_change(changeset, :end_at, end_at)
  end

  defp calculate_end_at(changeset), do: changeset
end
