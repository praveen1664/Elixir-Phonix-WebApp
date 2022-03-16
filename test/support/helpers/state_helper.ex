defmodule Mindful.Test.Support.StateHelper do
  @moduledoc """
  This module provides helpers for tests related to State.
  """
  alias Mindful.Factory
  alias Mindful.Locations.State

  @spec given_state(map) :: State.t()
  def given_state(attrs \\ %{}) do
    state_attrs = fetch_keys(attrs)

    Factory.insert(:state, state_attrs)
  end

  defp fetch_keys(attrs) do
    state_keys = Map.keys(%State{})

    Map.take(attrs, state_keys)
  end
end
