import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :mindful, Mindful.Repo,
  username: "postgres",
  password: "postgres",
  database: "mindful_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mindful, MindfulWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/u2/Ygk7sefifPcO/wrtQXpVt0IpidtXlCReUuyXl5W0jfzhxfsOgcInXrtX2cfH",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Environment variable for conditional code based on environment
config :mindful, :environment, :test

# Bamboo mailer config
config :mindful, Mindful.Mailers.Mailer, adapter: Bamboo.TestAdapter
config :bamboo, :refute_timeout, 10

config :sentry,
  dsn: "https://840971b82c9343ffbdc05b53d7a262bb@o1102072.ingest.sentry.io/6128230",
  environment_name: :test,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "test"
  },
  included_environments: [:test]

# config variables for S3 bucket
config :mindful, :bucket,
  name: "mindful-test",
  url_head: "https://mindful-test.com"
