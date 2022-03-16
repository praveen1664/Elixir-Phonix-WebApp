defmodule Mindful.Repo.Migrations.CreateJazzhrTables do
  use Ecto.Migration

  def change do
    create table(:jazzhr_applicants) do
      # This UUID is the id of the applicant in jazzhr
      add :uuid, :string
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :address, :string
      add :location, :string
      add :phone, :string
      add :linkedin_url, :string
      add :eco_gender, :string
      add :eco_race, :string
      add :desired_salary, :string
      add :referrer, :string
      add :apply_date, :utc_datetime
      add :source, :string
      add :recruiter_id, :string
      add :resume_link, :string
    end

    create unique_index(:jazzhr_applicants, [:uuid])

    create table(:jazzhr_jobs) do
      # This UUID is the id of the job in jazzhr
      add :uuid, :string
      add :title, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :department, :string
      add :original_open_date, :utc_datetime
      add :type, :string
      add :status, :string
      add :hiring_lead, :string
    end

    create unique_index(:jazzhr_jobs, [:uuid])

    create table(:jazzhr_applicant_to_jobs) do
      add :applicant_uuid, :string
      add :job_uuid, :string
      add :rating, :string
      add :workflow_step_id, :string
      add :workflow_step_name, :string
      add :hired_date, :utc_datetime
      add :date, :utc_datetime
    end

    create unique_index(:jazzhr_applicant_to_jobs, [:applicant_uuid, :job_uuid])

    create table(:jazzhr_users) do
      add :uuid, :string
      add :first_name, :string
      add :last_name, :string
    end
  end
end
