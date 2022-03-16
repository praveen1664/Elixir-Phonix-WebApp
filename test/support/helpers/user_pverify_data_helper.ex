defmodule Mindful.Test.Support.UserPverifyDataHelper do
  alias Mindful.Factory
  alias Mindful.Pverify.UserPverifyData

  def given_user_pverify_data(attrs \\ %{})

  def given_user_pverify_data(attrs) do
    user_id = Map.get(attrs, :user_id)
    user_pverify_data_attrs = attrs |> fetch_keys() |> Map.merge(%{user_id: user_id})

    Factory.insert(:user_pverify_data, user_pverify_data_attrs)
  end

  defp fetch_keys(attrs) do
    keys = Map.keys(%UserPverifyData{})
    Map.take(attrs, keys)
  end
end
