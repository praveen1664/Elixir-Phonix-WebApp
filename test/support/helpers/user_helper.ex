defmodule Mindful.Test.Support.UserHelper do
  @moduledoc """
  This module provides helpers for tests related to Users.
  """
  alias Mindful.Accounts.User
  alias Mindful.Factory

  def given_user(attrs \\ %{}) do
    confirmed_at = Map.get_lazy(attrs, :confirmed_at, &confirmed_at/0)

    user_attrs =
      attrs
      |> fetch_keys()
      |> Map.merge(%{confirmed_at: confirmed_at})

    Factory.insert(:user, user_attrs)
  end

  def given_admin_user(attrs \\ %{}) do
    attrs = Map.merge(attrs, %{superadmin: true})

    Factory.insert(:user, attrs)
  end

  def given_unconfirmed_user(attrs \\ %{}) do
    attrs = Map.merge(attrs, %{confirmed_at: nil})

    Factory.insert(:user, attrs)
  end

  @spec dob :: Date.t()
  def dob do
    {:ok, date} = Date.new(1990, 12, 31)
    date
  end

  ## Private Functions

  defp fetch_keys(attrs) do
    user_keys = Map.keys(%User{})

    Map.take(attrs, user_keys)
  end

  defp confirmed_at do
    now = NaiveDateTime.utc_now()

    NaiveDateTime.truncate(now, :second)
  end
end
