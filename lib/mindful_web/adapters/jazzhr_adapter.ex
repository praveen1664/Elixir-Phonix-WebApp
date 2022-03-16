defmodule MindfulWeb.JazzhrAdapter do
  @moduledoc """
  Adapter for working with the Jazz HR API.
  """
  alias MindfulWeb.Helpers.Utils

  def process_request do
    url =
      "https://api.resumatorapi.com/v1/jobs?apikey=" <>
        Application.get_env(:mindful, :jazzhr)[:api_key]

    request = HTTPoison.get(url, [{"Content-Type", "application/json"}])

    case request do
      {:ok, %{body: resp}} ->
        case Jason.decode(resp) do
          {:ok, jobs} ->
            jobs
            |> Enum.reject(&(&1["department"] == ""))
            |> Enum.reject(&(&1["status"] != "Open"))
            |> Enum.group_by(
              fn job -> job["department"] end,
              fn job ->
                url = "https://mindfulcare.applytojob.com/apply/" <> job["board_code"]
                location = job_location(job)

                state =
                  if job["state"] |> String.trim() == "",
                    do: "Remote",
                    else:
                      job["state"]
                      |> Utils.name_for_abbr()

                %{
                  job: job["title"],
                  state: state,
                  location: location,
                  type: job["type"],
                  url: url
                }
              end
            )
            |> Enum.map(fn {department, department_jobs} ->
              jobs_by_state =
                department_jobs
                |> Enum.group_by(& &1.state)
                |> Utils.convert_to_keyword_list()

              {department, jobs_by_state}
            end)

          _ ->
            nil
        end

      {:error, _error} ->
        nil
    end
  end

  def job_location(job) do
    case is_remote?(job) do
      true ->
        "Remote"

      false ->
        if job["city"] |> String.trim() == "",
          do: job["state"],
          else: job["city"] <> ", " <> job["state"]
    end
  end

  def is_remote?(%{"description" => description}) do
    possible_words = ["100% remote", "100% Remote"]
    String.contains?(description, possible_words)
  end

  def is_remote?(_) do
    # Log error
    false
  end
end
