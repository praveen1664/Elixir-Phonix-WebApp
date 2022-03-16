defmodule MindfulWeb.PverifyAdapterTest do
  use MindfulWeb.ConnCase
  import Mindful.Test.Support.{StateHelper, UserHelper, UserPverifyDataHelper}

  describe "Pverify self-verification workflow" do
    setup do
      given_state(%{abbr: "ny"})

      %{user: given_user(%{state_abbr: "ny"})}
    end

    test "Patient can verify eligibility", %{conn: conn, user: user} do
      user_pverify_data = given_user_pverify_data(%{payer_code: "Other Payers"})

      params = %{
        "user_pverify_data" => %{
          "payer_code" => user_pverify_data.payer_code,
          "provider_name" => user_pverify_data.provider_name,
          "provider_npi" => user_pverify_data.provider_npi,
          "subscriber_member_id" => user_pverify_data.subscriber_member_id
        }
      }

      conn =
        build_conn()
        |> log_in_user(user)
        |> post(Routes.user_path(conn, :update_insurance_details, params))

      assert redirected_to(conn) == "/dash/insurance"
      assert get_flash(conn, :info) == "Verification details submitted"

      user = Mindful.Accounts.get_user!(user.id)
      refute user.pverify_eligibility_verified
      assert user.user_pverify_data.payer_code == "Other Payers"
    end
  end
end
