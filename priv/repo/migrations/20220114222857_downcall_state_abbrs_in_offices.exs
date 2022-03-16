defmodule Mindful.Repo.Migrations.DowncallStateAbbrsInOffices do
  use Ecto.Migration

  def change do
    execute("""
    UPDATE offices
    SET state_abbr = LOWER(state_abbr)
    """)
  end
end
