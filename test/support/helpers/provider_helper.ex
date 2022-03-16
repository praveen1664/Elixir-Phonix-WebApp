defmodule Mindful.Test.Support.ProviderHelper do
  @moduledoc """
  Set of helper functions for Provider model
  """
  alias Mindful.Clinicians.Provider
  alias Mindful.Factory
  alias Mindful.Test.Support.OfficeHelper

  def given_provider(attrs \\ %{})

  def given_provider(%{office: office} = attrs) do
    provider_attrs =
      attrs
      |> fetch_keys()
      |> Map.merge(%{offices: [office]})

    Factory.insert(:provider, provider_attrs)
  end

  def given_provider(attrs) do
    office = OfficeHelper.given_office(attrs)

    attrs
    |> Map.merge(%{office: office})
    |> given_provider()
  end

  ## Private Functions

  defp fetch_keys(attrs) do
    provider_keys = Map.keys(%Provider{})

    Map.take(attrs, provider_keys)
  end
end
