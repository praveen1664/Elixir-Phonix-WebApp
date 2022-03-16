defmodule Mindful.Test.Support.OfficeHelper do
  alias Mindful.Factory
  alias Mindful.Locations.Office

  def given_office(attrs \\ %{})

  def given_office(%{state: _} = attrs) do
    office_attrs = fetch_keys(attrs)

    Factory.insert(:office, office_attrs)
  end

  def given_office(attrs) do
    state = Factory.insert(:state, attrs)

    attrs
    |> Map.merge(%{state: state})
    |> given_office()
  end

  ## Private Functions

  defp fetch_keys(attrs) do
    office_keys = Map.keys(%Office{})

    Map.take(attrs, office_keys)
  end
end
