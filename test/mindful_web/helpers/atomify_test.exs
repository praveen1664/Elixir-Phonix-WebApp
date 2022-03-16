defmodule MindfulWeb.Helpers.AtomifyTest do
  use ExUnit.Case
  doctest MindfulWeb.Helpers.Atomify

  alias MindfulWeb.Helpers.Atomify

  test "keys_to_atoms with Plug.Upload returns right map" do
    upload = %Plug.Upload{}
    new_map = Atomify.keys_to_atoms(%{"string" => upload, "map" => %{"string" => "value"}})
    assert new_map == %{string: upload, map: %{string: "value"}}
  end

  test "keys_to_atoms with NaiveDateTime returns right map" do
    datetime = %NaiveDateTime{
      year: 2000,
      month: 2,
      day: 29,
      hour: 23,
      minute: 0,
      second: 7,
      microsecond: {0, 0}
    }

    new_map = Atomify.keys_to_atoms(%{"string" => datetime, "map" => %{"string" => "value"}})
    assert new_map == %{string: datetime, map: %{string: "value"}}
  end

  test "keys_to_atoms with DateTime returns right map" do
    datetime = %DateTime{
      year: 2000,
      month: 2,
      day: 29,
      zone_abbr: "AMT",
      hour: 23,
      minute: 0,
      second: 7,
      microsecond: {0, 0},
      utc_offset: -14_400,
      std_offset: 0,
      time_zone: "America/Manaus"
    }

    new_map = Atomify.keys_to_atoms(%{"string" => datetime, "map" => %{"string" => "value"}})
    assert new_map == %{string: datetime, map: %{string: "value"}}
  end

  test "keys_to_atoms with Date returns right map" do
    date = %Date{
      year: 2000,
      month: 2,
      day: 29
    }

    new_map = Atomify.keys_to_atoms(%{"string" => date, "map" => %{"string" => "value"}})
    assert new_map == %{string: date, map: %{string: "value"}}
  end

  test "keys_to_atoms with Time returns right map" do
    time = %Time{
      hour: 23,
      minute: 0,
      second: 7,
      microsecond: {0, 0}
    }

    new_map = Atomify.keys_to_atoms(%{"string" => time, "map" => %{"string" => "value"}})
    assert new_map == %{string: time, map: %{string: "value"}}
  end
end
