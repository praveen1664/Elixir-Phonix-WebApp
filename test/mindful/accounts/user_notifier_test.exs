defmodule Mindful.Accounts.UserNotifierTest do
  use Mindful.DataCase, async: true
  use Bamboo.Test
  import Mindful.Test.Support.{UserHelper, UserPverifyDataHelper}
  alias Mindful.Accounts.UserNotifier
  alias Mindful.Mailers.Email

  setup do
    %{user: given_user(), user_pverify_data: given_user_pverify_data()}
  end

  describe "Deductible info email" do
    test "Sends email successfully", %{user: user, user_pverify_data: user_pverify_data} do
      amount = 10
      expected_email = Email.deductible_info(user, user_pverify_data, amount)

      UserNotifier.deliver_deductible_notification(user, user_pverify_data, amount)
      assert_delivered_email(expected_email)
    end
  end
end
