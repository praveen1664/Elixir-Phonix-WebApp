defmodule MindfulWeb.Services.TokensCache do
  @moduledoc """
  A Cachex cache for storing access tokens to third-party services.
  """
  alias Mindful.Accounts
  alias MindfulWeb.DrchronoAdapter

  # cachex table name
  @tab :services_tokens_cache

  # service keys
  @help_scout_cache_key "help_scout_token"
  @drchrono_cache_key "drchrono_token"
  @pverify_cache_key "pverify_token"

  @superadmin_email "mcadenhead@mindful.care"

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  ## Client

  def start_link do
    Cachex.start_link(@tab, [])
  end

  def fetch_help_scout_token() do
    case Cachex.get(@tab, @help_scout_cache_key) do
      {:ok, nil} ->
        fetch_and_cache_help_scout_token()

      {:ok, token} ->
        token
    end
  end

  defp fetch_and_cache_help_scout_token() do
    {token, timeout} = MindfulWeb.HelpScoutAdapter.generate_token()

    {:ok, true} = Cachex.put(@tab, @help_scout_cache_key, token, ttl: :timer.seconds(timeout))
    token
  end

  def store_drchrono_token(data) do
    Cachex.put(
      @tab,
      @drchrono_cache_key,
      %{token: data[:token], refresh_token: data[:refresh_token], expires_at: data[:expires_at]}
    )
  end

  # Checks for a valid, non-expired token. This assumes that a token is always present in the cache
  def get_drchrono_token() do
    case Cachex.get(@tab, @drchrono_cache_key) do
      {:ok, %{token: token} = data} ->
        time_diff = NaiveDateTime.compare(data[:expires_at], NaiveDateTime.utc_now())

        if time_diff in [:lt, :eq] do
          {:ok, token_data} = DrchronoAdapter.exchange_refresh_token(data[:refresh_token])

          {:ok, _} =
            store_drchrono_token(%{
              token: token_data.drchrono_oauth_token,
              refresh_token: token_data.drchrono_oauth_refresh_token,
              expires_at: token_data.drchrono_oauth_expires_at
            })

          token_data.drchrono_oauth_token
        else
          token
        end

      _ ->
        # If there is no token in the cache (e.g. upon a server restart),
        # Use admin's stored drchrono_oauth_refresh_token to obtain a new one
        with %Mindful.Accounts.User{} = admin <- Accounts.get_user_by_email(@superadmin_email),
             refresh_token <- admin.drchrono_oauth_refresh_token,
             {:ok, token_data} <- DrchronoAdapter.exchange_refresh_token(refresh_token) do
          Accounts.save_chrono_auth_info!(admin, token_data)

          {:ok, _} =
            store_drchrono_token(%{
              token: token_data.drchrono_oauth_token,
              refresh_token: token_data.drchrono_oauth_refresh_token,
              expires_at: token_data.drchrono_oauth_expires_at
            })

          token_data.drchrono_oauth_token
        else
          nil ->
            :no_token

          {:error, _error} ->
            :token_exchange_failed
        end
    end
  end

  def fetch_pverify_token() do
    case Cachex.get(@tab, @pverify_cache_key) do
      {:ok, nil} ->
        fetch_and_cache_pverify_token()

      {:ok, token} ->
        token
    end
  end

  defp fetch_and_cache_pverify_token() do
    {token, timeout} = MindfulWeb.PverifyAdapter.generate_token()
    {:ok, true} = Cachex.put(@tab, @pverify_cache_key, token, ttl: :timer.seconds(timeout))
    token
  end
end
