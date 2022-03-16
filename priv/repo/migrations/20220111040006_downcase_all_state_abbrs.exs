defmodule Mindful.Repo.Migrations.DowncaseAllStateAbbrs do
  use Ecto.Migration

  def change do
    execute("""
    UPDATE states
    SET abbr = LOWER(abbr)
    """)
  end
end
