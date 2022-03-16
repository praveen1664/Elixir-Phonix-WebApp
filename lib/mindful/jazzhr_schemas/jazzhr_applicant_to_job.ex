defmodule Mindful.JazzhrSchemas.JazzhrApplicantToJob do
  @moduledoc """
  This is the schema for associating applicansts and jobs from the Jazzhr API.
  """

  use Ecto.Schema

  schema "jazzhr_applicant_to_jobs" do
    field :applicant_uuid, :string
    field :job_uuid, :string
    field :rating, :string
    field :workflow_step_id, :string
    field :workflow_step_name, :string
    field :hired_date, :utc_datetime
    field :date, :utc_datetime
  end
end
