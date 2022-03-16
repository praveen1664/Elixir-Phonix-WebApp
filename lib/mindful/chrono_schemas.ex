defmodule Mindful.ChronoSchemas do
  @moduledoc """
  The Chrono Schemas context.
  """

  import Ecto.Query
  alias Mindful.Repo

  alias Mindful.ChronoSchemas.{
    DrchronoPatient,
    DrchronoAppointment,
    DrchronoLineItem,
    DrchronoProblem,
    DrchronoMedication,
    DrchronoDoctor,
    DrchronoOffice
  }

  @doc """
  Inserts a new patient into the database or updates an existing one if it already exists.
  """
  @spec upsert_patient!(map()) :: DrchronoPatient.t()
  def upsert_patient!(params) do
    patient = MindfulWeb.Services.DrchronoDbCopier.normalize_patient_data(params)
    changeset = Ecto.Changeset.change(%DrchronoPatient{}, patient)
    Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]}, conflict_target: :uuid)
  end

  @doc """
  Inserts a new appointment into the database or updates an existing one if it already exists.
  """
  @spec upsert_appointment!(map()) :: DrchronoAppointment.t()
  def upsert_appointment!(params) do
    appointment = MindfulWeb.Services.DrchronoDbCopier.normalize_appointment_data(params)
    changeset = Ecto.Changeset.change(%DrchronoAppointment{}, appointment)
    Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]}, conflict_target: :uuid)
  end

  @doc """
  Inserts a new line_item into the database or updates an existing one if it already exists.
  """
  @spec upsert_line_item!(map()) :: DrchronoLineItem.t()
  def upsert_line_item!(params) do
    line_item = MindfulWeb.Services.DrchronoDbCopier.normalize_line_item_data(params)
    changeset = Ecto.Changeset.change(%DrchronoLineItem{}, line_item)
    Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]}, conflict_target: :uuid)
  end

  @doc """
  Inserts a new medication into the database or updates an existing one if it already exists.
  """
  @spec upsert_medication!(map()) :: DrchronoMedication.t()
  def upsert_medication!(params) do
    medication = MindfulWeb.Services.DrchronoDbCopier.normalize_medication_data(params)
    changeset = Ecto.Changeset.change(%DrchronoMedication{}, medication)
    Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]}, conflict_target: :uuid)
  end

  @doc """
  Inserts a new problem into the database or updates an existing one if it already exists.
  """
  @spec upsert_problem!(map()) :: DrchronoProblem.t()
  def upsert_problem!(params) do
    problem = MindfulWeb.Services.DrchronoDbCopier.normalize_problem_data(params)
    changeset = Ecto.Changeset.change(%DrchronoProblem{}, problem)
    Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]}, conflict_target: :uuid)
  end

  @spec get_patient_to_broadcast(integer()) :: DrchronoPatient.t()
  def get_patient_to_broadcast(drchrono_patient_uuid) do
    now = DateTime.utc_now()

    DrchronoPatient
    |> join(:left, [p], a in DrchronoAppointment, on: a.patient == ^drchrono_patient_uuid)
    |> join(:left, [..., a], o in DrchronoOffice, on: o.uuid == a.office)
    |> join(:inner, [p, ...], prob in DrchronoProblem, on: prob.patient == ^drchrono_patient_uuid)
    |> join(:inner, [p, ...], m in DrchronoMedication, on: m.patient == ^drchrono_patient_uuid)
    |> join(:inner, [p, ...], d in DrchronoDoctor, on: d.uuid == p.doctor)
    |> where([p, ...], p.uuid == ^drchrono_patient_uuid)
    |> where([p, a, ...], a.scheduled_time > ^now)
    |> group_by([p, ..., d], [p.id, d.id])
    |> select([p, a, o, prob, m, d], %{
      patient: p,
      problems: fragment("array_agg(?)", prob.name),
      medications: fragment("array_agg(?)", m.name),
      doctor: fragment("concat(?, ' ', ?, ' ', ?)", d.suffix, d.first_name, d.last_name),
      office: fragment("array_agg(?)", o.name),
      future_appointments: fragment("array_agg(?)", a.scheduled_time)
    })
    |> Repo.one()
  end
end
