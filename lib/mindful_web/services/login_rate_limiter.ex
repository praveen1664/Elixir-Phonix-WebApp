defmodule MindfulWeb.Services.LoginRateLimiter do
  @moduledoc """
  MindfulWeb.Services.LoginRateLimiter module
  """

  use GenServer
  require Logger

  @max_per_four_minutes 4
  @sweep_after :timer.minutes(5)
  @tab :login_rate_limiter_requests

  ## Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Increments a counter to track when a user_ip has failed to login.
  """
  def log_failed_attempt(user_ip) do
    case :ets.update_counter(@tab, user_ip, {2, 1}, {user_ip, 0}) do
      count when count > @max_per_four_minutes -> {:error, :rate_limited}
      _count -> :ok
    end
  end

  @doc """
  Returns a list of the recent number of failed attempts got a user_ip.
  """
  def recent_attempts(user_ip) do
    case :ets.lookup(@tab, user_ip) do
      [{_phone, attempts}] -> attempts
      _ -> 0
    end
  end

  ## Server
  def init(_) do
    :ets.new(@tab, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    schedule_sweep()
    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    :ets.delete_all_objects(@tab)
    schedule_sweep()
    {:noreply, state}
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_after)
  end
end
