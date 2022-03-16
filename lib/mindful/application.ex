defmodule Mindful.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

    children = [
      # Start the Ecto repository
      Mindful.Repo,
      # Start the Telemetry supervisor
      MindfulWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mindful.PubSub},
      # Start the Endpoint (http/https)
      MindfulWeb.Endpoint,
      # Start rate limiter process for logging in
      MindfulWeb.Services.LoginRateLimiter,
      # start quantum job scheduler
      Mindful.Scheduler,
      # Jazzhr cache worker process
      MindfulWeb.Services.JazzhrCache,
      # Third-party tokens cache process
      MindfulWeb.Services.TokensCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mindful.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MindfulWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
