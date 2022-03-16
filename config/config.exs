# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :mindful,
  ecto_repos: [Mindful.Repo]

config :mindful, Mindful.Repo,
  migration_timestamps: [type: :utc_datetime_usec],
  telemetry_prefix: [:repo]

config :mindful, Mindful.Appointments.TimeSlots,
  time_zone: "America/New_York",
  # start of working day hours
  day_start: 8,
  # end of working day hours
  day_end: 19

# Configures the endpoint
config :mindful, MindfulWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MindfulWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mindful.PubSub,
  live_view: [signing_salt: "bYEufVTp"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# stripity stripe cofig
config :stripity_stripe,
  api_key: System.get_env("STRIPE_NY_SECRET"),
  json_library: Jason,
  hackney_opts: [{:recv_timeout, 15_000}]

config :mindful, :stripe_ny,
  api_key: System.get_env("STRIPE_NY_SECRET"),
  public_key: System.get_env("STRIPE_NY_PUBLIC_KEY"),
  wh_secret: System.get_env("STRIPE_NY_WEBHOOK_INDEX_SECRET")

config :mindful, :stripe_nj,
  api_key: System.get_env("STRIPE_NJ_SECRET"),
  public_key: System.get_env("STRIPE_NJ_PUBLIC_KEY"),
  wh_secret: System.get_env("STRIPE_NJ_WEBHOOK_INDEX_SECRET")

config :mindful, :stripe_il,
  api_key: System.get_env("STRIPE_IL_SECRET"),
  public_key: System.get_env("STRIPE_IL_PUBLIC_KEY"),
  wh_secret: System.get_env("STRIPE_IL_WEBHOOK_INDEX_SECRET")

# config for drchrono
config :mindful, :drchrono,
  client_id: System.get_env("DRCHRONO_CLIENT_ID"),
  secret: System.get_env("DRCHRONO_CLIENT_SECRET"),
  webhook_secret: System.get_env("DRCHRONO_WEBHOOK_SECRET")

# config for general things like a local ngrok host url
config :mindful, :general, host_url: System.get_env("HOST_URL")

# ex_aws config
config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: "us-east-1",
  json_codec: Jason

# config variables for S3 bucket
config :mindful, :bucket,
  name: System.get_env("S3_BUCKET_NAME"),
  url_head: System.get_env("S3_BUCKET_URL_HEAD")

# config for hcaptcha
config :mindful, :hcaptcha,
  sitekey: System.get_env("HCAPTCHA_SITEKEY"),
  secret: System.get_env("HCAPTCHA_SECRET")

# config variables for Jazz HR
config :mindful, :jazzhr, api_key: System.get_env("JAZZHR_API_KEY")

# config for pverify
config :mindful, :pverify,
  client_id: System.get_env("PVERIFY_CLIENT_ID"),
  secret: System.get_env("PVERIFY_CLIENT_SECRET")

# Config quantum job scheduler
config :mindful, Mindful.Scheduler,
  timeout: 30_000,
  timezone: "America/New_York",
  jobs: [
    {"@hourly", {MindfulWeb.Services.JazzhrCache, :fetch, []}}
  ]

config :mindful, :google_maps, api_key: System.get_env("GOOGLE_MAPS_API_KEY")

config :mindful, :google_mybusiness,
  client_id: System.get_env("GOOGLE_MY_BUSINESS_CLIENT_ID"),
  account_id: System.get_env("GOOGLE_MY_BUSINESS_ACCOUNT_ID")

config :mindful, :ipinfo, token: System.get_env("IPINFO_TOKEN")

# Help Scout config
config :mindful, :helpscout,
  id: System.get_env("HELP_SCOUT_APP_ID"),
  secret: System.get_env("HELP_SCOUT_APP_SECRET")

# Active Campaign config
config :mindful, :activecampaign,
  base_url: System.get_env("ACTIVE_CAMPAIGN_API_URL"),
  api_key: System.get_env("ACTIVE_CAMPAIGN_KEY")

# Ring Central
config :mindful, :ringcentral,
  base_url: System.get_env("RING_CENTRAL_API_URL", "localhost"),
  id: System.get_env("RING_CENTRAL_CLIENT_ID", ""),
  secret: System.get_env("RING_CENTRAL_CLIENT_SECRET", ""),
  extension: System.get_env("RING_CENTRAL_CLIENT_SECRET", ""),
  username: System.get_env("RING_CENTRAL_CLIENT_SECRET", ""),
  password: System.get_env("RING_CENTRAL_CLIENT_SECRET", "")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
