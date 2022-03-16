defmodule Mindful.LocationsTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.OfficeHelper
  import Mindful.Test.Support.ProviderHelper
  import Mindful.Test.Support.StateHelper

  alias Mindful.Locations
  doctest Mindful.Locations

  setup do
    {:ok, office: given_office()}
  end

  describe "list_offices_for_state/1" do
    test "returns all offices for given state", %{office: office} do
      provider = given_provider(%{office: office})
      [off] = Locations.list_offices_for_state(office.state)

      assert Ecto.assoc_loaded?(off.providers)
      assert off.id == office.id
      assert [prov] = off.providers
      assert prov.id == provider.id
    end

    test "returns all offices for given state abbreviation", %{office: office} do
      [off] = Locations.list_offices_for_state(office.state_abbr)
      assert off.id == office.id
    end

    test "returns empty list with invalid param" do
      assert [] = Locations.list_offices_for_state(123)
    end
  end

  describe "get_state_by_abbr/1" do
    test "when given nil returns nil" do
      assert is_nil(Locations.get_state_by_abbr(nil))
    end

    test "when given abbr does not exist return nil" do
      assert is_nil(Locations.get_state_by_abbr("not-valid"))
    end

    test "when given abbr that is not binary return nil" do
      assert is_nil(Locations.get_state_by_abbr(1))
    end

    test "when given a valid abbr return a state" do
      state = given_state(%{state: "My state", abbr: "ms", slug: "ms-slug"})

      assert state.name == Locations.get_state_by_abbr(state.abbr).name
      assert state.abbr == Locations.get_state_by_abbr(state.abbr).abbr
    end

    test "when given a valid abbr with upcase letters return a state" do
      state = given_state(%{state: "My state", abbr: "ms", slug: "ms-slug"})

      assert state.name == Locations.get_state_by_abbr(state.abbr).name
      assert state.abbr == Locations.get_state_by_abbr(state.abbr).abbr
    end
  end
end
