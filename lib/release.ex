defmodule Mindful.Release do
  @moduledoc """
  Mindful.Release module
  """

  @app :mindful

  def migrate do
    ensure_started()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    ensure_started()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp ensure_started do
    Application.ensure_all_started(:ssl)
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
