defmodule Mix.Tasks.PopulateAvailableTreatments do
  use Mix.Task

  @shortdoc "Populate column available_treatments for State changeset"

  alias Mindful.Locations

  @moduledoc """
  Populate column available_treatments for State changeset
  """
  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("Update states.available_treatments for new-jersey")
    state = Locations.get_state_by_slug("new-jersey")

    {:ok, _} =
      Locations.update_state(state, %{
        "available_treatments" => ["medical_management", "therapy", "substance_use_counseling"]
      })

    Mix.shell().info("Update states.available_treatments for new-york")
    state = Locations.get_state_by_slug("new-york")

    {:ok, _} =
      Locations.update_state(state, %{
        "available_treatments" => ["medical_management", "therapy", "substance_use_counseling"]
      })

    Mix.shell().info("Update states.available_treatments for illinois")
    state = Locations.get_state_by_slug("illinois")
    {:ok, _} = Locations.update_state(state, %{"available_treatments" => ["medical_management"]})
  end
end
