defmodule MindfulWeb.Services.JazzhrDbCopier do
  @moduledoc """
  Used alongside Quantum to schedule regular backups of Jazzhr.com data to our production database.
  """

  alias Mindful.Repo

  alias Mindful.JazzhrSchemas.{JazzhrApplicant, JazzhrJob, JazzhrApplicantToJob, JazzhrUser}

  @doc """
  Deletes all Jazzhr data from our database.
  """
  def delete_stale_data do
    Task.start(fn -> delete_jazzhr_data() end)
  end

  defp delete_jazzhr_data do
    Repo.delete_all(JazzhrApplicant)
    Repo.delete_all(JazzhrJob)
    Repo.delete_all(JazzhrApplicantToJob)
    Repo.delete_all(JazzhrUser)
  end

  @doc """
  Go through each Jazzhr resource and insert the resulting lists into our db.
  """
  def copy_all_data do
    # Task.start(fn -> insert_drchrono_data() end)
    insert_jazzhr_data()
  end

  def insert_jazzhr_data do
    download_applicants()
    download_jobs()
    download_applicant_to_jobs()
    download_hires()
    download_users()
  end

  # Fetches applicants from Jazzhr and inserts them into our database.
  def download_applicants() do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]
    base_uri = "https://api.resumatorapi.com/v1/applicants"
    ranges = all_date_ranges()

    Enum.map(ranges, fn {from_date, to_date} ->
      IO.puts("Fetching applicants from #{from_date} to #{to_date}")
      insert_applicants_by_date_range({from_date, to_date}, token, base_uri)
    end)
  end

  def insert_applicants_by_date_range({from_date, to_date}, token, base_uri, page \\ 1) do
    params = "/from_apply_date/#{from_date}/to_apply_date/#{to_date}?apikey=#{token}"
    uri = base_uri <> "/page/#{page}" <> params
    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        data = Jason.decode!(resp)
        IO.puts("Downloading #{length(data)} applicants. Page #{page}.")
        data_unique = Enum.uniq_by(data, & &1["id"])
        applicants = Enum.map(data_unique, &fetch_and_normalize_applicant_data(&1["id"]))

        Repo.insert_all(JazzhrApplicant, applicants,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if length(data) == 100 do
          # Since we have a max of 100 responses per page, we need to make another request
          insert_applicants_by_date_range({from_date, to_date}, token, base_uri, page + 1)
        else
          # No more data to fetch.
          IO.puts("Done fetching applicants.")
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        insert_applicants_by_date_range({from_date, to_date}, token, base_uri, page)
    end
  end

  def fetch_and_normalize_applicant_data(applicant_id) do
    applicant = fetch_data_by_applicant_id(applicant_id)

    %{
      uuid: applicant["id"],
      first_name: applicant["first_name"],
      last_name: applicant["last_name"],
      email: applicant["email"],
      address: applicant["address"],
      location: applicant["location"],
      phone: applicant["phone"],
      linkedin_url: applicant["linkedin_url"],
      eco_gender: applicant["eco_gender"],
      eco_race: applicant["eco_race"],
      desired_salary: applicant["desired_salary"],
      referrer: applicant["referrer"],
      apply_date: cast_to_datetime(applicant["apply_date"]),
      source: applicant["source"],
      recruiter_id: applicant["recruiter_id"],
      resume_link: applicant["resume_link"]
    }
  end

  def fetch_data_by_applicant_id(applicant_id) do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]
    uri = "https://api.resumatorapi.com/v1/applicants/#{applicant_id}?apikey=#{token}"

    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        Jason.decode!(resp)

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        fetch_data_by_applicant_id(applicant_id)
    end
  end

  def download_jobs(page \\ 1) do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]
    uri = "https://api.resumatorapi.com/v1/jobs" <> "/page/#{page}" <> "?apikey=#{token}"
    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        data = Jason.decode!(resp)
        IO.puts("Downloading #{length(data)} jobs. Page #{page}.")
        data_unique = Enum.uniq_by(data, & &1["id"])
        jobs = Enum.map(data_unique, &normalize_job_data(&1))

        Repo.insert_all(JazzhrJob, jobs,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: :uuid
        )

        if length(data) == 100 do
          # Since we have a max of 100 responses per page, we need to make another request
          download_jobs(page + 1)
        else
          # No more data to fetch.
          IO.puts("Done fetching jobs.")
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_jobs(page)
    end
  end

  defp normalize_job_data(job) do
    %{
      uuid: job["id"],
      title: job["title"],
      city: job["city"],
      state: job["state"],
      zip: job["zip"],
      department: job["department"],
      original_open_date: cast_to_datetime(job["original_open_date"]),
      type: job["type"],
      status: job["status"],
      hiring_lead: job["hiring_lead"]
    }
  end

  def download_applicant_to_jobs(page \\ 1) do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]

    uri =
      "https://api.resumatorapi.com/v1/applicants2jobs" <> "/page/#{page}" <> "?apikey=#{token}"

    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        data = Jason.decode!(resp)
        IO.puts("Downloading #{length(data)} applicants to jobs. Page #{page}.")
        data_unique = Enum.uniq_by(data, & &1["id"])
        applicant_to_jobs = Enum.map(data_unique, &normalize_applicant_to_job_data(&1))

        Repo.insert_all(JazzhrApplicantToJob, applicant_to_jobs,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: [:applicant_uuid, :job_uuid]
        )

        if length(data) == 100 do
          # Since we have a max of 100 responses per page, we need to make another request
          download_applicant_to_jobs(page + 1)
        else
          # No more data to fetch.
          IO.puts("Done fetching applicants to jobs.")
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_applicant_to_jobs(page)
    end
  end

  defp normalize_applicant_to_job_data(applicant_to_job) do
    %{
      applicant_uuid: applicant_to_job["applicant_id"],
      job_uuid: applicant_to_job["job_id"],
      rating: applicant_to_job["rating"],
      workflow_step_id: applicant_to_job["workflow_step_id"],
      workflow_step_name: applicant_to_job["workflow_step_name"],
      hired_date: cast_to_datetime(applicant_to_job["hired_date"]),
      date: cast_to_datetime(applicant_to_job["date"])
    }
  end

  def download_hires(page \\ 1) do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]

    uri = "https://api.resumatorapi.com/v1/hires" <> "/page/#{page}" <> "?apikey=#{token}"

    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        data = Jason.decode!(resp)
        IO.puts("Downloading #{length(data)} hires. Page #{page}.")
        data_unique = Enum.uniq_by(data, & &1["id"])
        hires = Enum.map(data_unique, &normalize_hire_data(&1))

        Repo.insert_all(JazzhrApplicantToJob, hires,
          on_conflict: {:replace_all_except, [:id, :date, :rating]},
          conflict_target: [:applicant_uuid, :job_uuid]
        )

        if length(data) == 100 do
          # Since we have a max of 100 responses per page, we need to make another request
          download_hires(page + 1)
        else
          # No more data to fetch.
          IO.puts("Done fetching hires.")
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_hires(page)
    end
  end

  defp normalize_hire_data(hire) do
    %{
      applicant_uuid: hire["applicant_id"],
      job_uuid: hire["job_id"],
      rating: hire["rating"],
      workflow_step_id: hire["workflow_step_id"],
      workflow_step_name: hire["workflow_step_name"],
      hired_date: cast_to_datetime(hire["hired_date"]),
      date: cast_to_datetime(hire["date"])
    }
  end

  def download_users(page \\ 1) do
    token = Application.get_env(:mindful, :jazzhr)[:api_key]

    uri = "https://api.resumatorapi.com/v1/users" <> "/page/#{page}" <> "?apikey=#{token}"

    request = HTTPoison.get(uri, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        data = Jason.decode!(resp)
        IO.puts("Downloading #{length(data)} users. Page #{page}.")
        users = Enum.map(data, &normalize_user_data(&1))
        Repo.insert_all(JazzhrUser, users)

        if length(data) == 100 do
          # Since we have a max of 100 responses per page, we need to make another request
          download_users(page + 1)
        else
          # No more data to fetch.
          IO.puts("Done fetching users.")
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        IO.puts("Timeout. Waiting 2 seconds and trying again.")
        :timer.sleep(:timer.seconds(2))
        download_users(page)
    end
  end

  defp normalize_user_data(user) do
    %{
      uuid: user["id"],
      first_name: user["first_name"],
      last_name: user["last_name"]
    }
  end

  defp cast_to_datetime(nil), do: nil
  defp cast_to_datetime("0000-00-00"), do: nil

  defp cast_to_datetime(timestamp) do
    # example format from drchrono API: "2019-05-22T13:00:00"
    case Timex.parse(timestamp, "%Y-%m-%dT%H:%M:%S", :strftime) do
      {:ok, time} ->
        Timex.to_datetime(time)

      {:error, _} ->
        # Try parsing for only day. Example format from drchrono API for date: "1979-06-04"
        Timex.to_datetime(Timex.parse!(timestamp, "%Y-%m-%d", :strftime))
    end
  end

  defp all_date_ranges do
    [
      {"2021-09-01", "2021-10-01"},
      {"2021-10-02", "2021-11-01"},
      {"2021-11-02", "2021-12-01"},
      {"2021-12-02", "2022-01-01"},
      {"2022-01-02", "2022-02-01"},
      {"2022-02-02", "2022-03-01"},
      {"2022-03-02", "2022-04-01"},
      {"2022-04-02", "2022-05-01"},
      {"2022-05-02", "2022-06-01"}
    ]
  end
end
