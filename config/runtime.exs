import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :mindful, Mindful.Repo,
    # ssl: true,
    # socket_options: [:inet6],
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :mindful, MindfulWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  config :mindful, MindfulWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # production config below

  # Configure bamboo email to use Mailgun adapter
  config :mindful, Mindful.Mailers.Mailer,
    adapter: Bamboo.MailgunAdapter,
    api_key: System.get_env("MAILGUN_API_KEY"),
    domain: System.get_env("MAILGUN_DOMAIN")

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
end
