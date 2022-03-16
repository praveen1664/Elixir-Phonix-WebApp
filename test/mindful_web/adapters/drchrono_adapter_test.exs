defmodule MindfulWeb.DrChronoAdapterTest do
  use MindfulWeb.ConnCase
  alias MindfulWeb.DrchronoAdapter

  test "Handles fetching of patient without a drchrono_id" do
    patient = DrchronoAdapter.fetch_patient(nil)
    assert is_nil(patient)
  end
end
