defmodule MindfulWeb.TokensCacheTest do
  use MindfulWeb.ConnCase, async: true
  alias MindfulWeb.Services.TokensCache

  setup do
    {:ok, true} = Cachex.del(:services_tokens_cache, "drchrono_token")
    :ok
  end

  test "Token not present in cache" do
    assert TokensCache.get_drchrono_token() == :no_token
  end

  test "Valid token present in cache" do
    expires_at = NaiveDateTime.utc_now() |> Timex.shift(days: 1)
    token = Faker.String.base64(10)

    {:ok, true} =
      TokensCache.store_drchrono_token(%{
        token: token,
        refresh_token: Faker.String.base64(10),
        expires_at: expires_at
      })

    assert TokensCache.get_drchrono_token() == token
  end

  test "Expired token present in cache" do
    # TODO
  end
end
