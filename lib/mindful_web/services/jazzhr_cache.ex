defmodule MindfulWeb.Services.JazzhrCache do
  @moduledoc """
  A Cachex cache for the jobs we have posted on Jazz HR.
  """

  # cachex table name
  @tab :jazzhr_cache

  # cachex table key that all jobs are stored under
  @cache_key "jobs"

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  ## Client

  def start_link do
    Cachex.start_link(@tab, [])
  end

  @cache_key "jobs"

  def fetch_all_jobs() do
    case Cachex.get(@tab, @cache_key) do
      {:ok, nil} ->
        case fetch() do
          {:ok, data} ->
            data

          _ ->
            []
        end

      {:ok, data} ->
        data
    end
  end

  def fetch() do
    case MindfulWeb.JazzhrAdapter.process_request() do
      nil ->
        nil

      data ->
        store(data)
    end
  end

  defp store(data) do
    case Cachex.put(@tab, @cache_key, data) do
      {:ok, true} ->
        Cachex.expire(@tab, @cache_key, :timer.minutes(60))
        {:ok, data}

      _ ->
        []
    end
  end
end
