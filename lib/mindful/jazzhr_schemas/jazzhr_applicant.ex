defmodule Mindful.JazzhrSchemas.JazzhrApplicant do
  @moduledoc """
  This is the schema for a job from the Jazzhr API.
  """

  use Ecto.Schema

  schema "jazzhr_applicants" do
    field :uuid, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :address, :string
    field :location, :string
    field :phone, :string
    field :linkedin_url, :string
    field :eco_gender, :string
    field :eco_race, :string
    field :desired_salary, :string
    field :referrer, :string
    field :apply_date, :utc_datetime
    field :source, :string
    field :recruiter_id, :string
    field :resume_link, :string
  end
end
