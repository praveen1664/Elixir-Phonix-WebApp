defmodule Mindful.Repo do
  use Ecto.Repo,
    otp_app: :mindful,
    adapter: Ecto.Adapters.Postgres
end
