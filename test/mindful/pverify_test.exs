defmodule Mindful.PverifyTest do
  use Mindful.DataCase, async: true
  alias Mindful.Pverify

  describe "payer_codes" do
    test "with a valid state, returns list of payers for that state" do
      universal_payers_list = Pverify.universal_payers()

      il_payers_list = Pverify.payer_codes("il")
      nj_payers_list = Pverify.payer_codes("nj")
      ny_payers_list = Pverify.payer_codes("ny")

      assert universal_payers_list |> Enum.all?(&Enum.member?(il_payers_list, &1))
      assert universal_payers_list |> Enum.all?(&Enum.member?(nj_payers_list, &1))
      assert universal_payers_list |> Enum.all?(&Enum.member?(ny_payers_list, &1))

      assert length(il_payers_list) > length(universal_payers_list)
      assert length(nj_payers_list) > length(universal_payers_list)
      assert length(ny_payers_list) > length(universal_payers_list)
    end

    test "with an unsupported state, returns list of universal payers" do
      payers_list = Pverify.payer_codes("unsupported_state_abbr")
      assert payers_list == Pverify.universal_payers()
    end

    test "with no state provided, returns list of universal payers" do
      assert Pverify.payer_codes() == Pverify.universal_payers()
    end
  end

  describe "payer_code_names" do
    test "last item of list shown to user is Other Payers" do
      assert Pverify.payer_code_names("ny") |> List.last() == "Other Payers"
      assert Pverify.payer_code_names("other_state") |> List.last() == "Other Payers"
    end
  end
end
