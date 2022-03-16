defmodule Mindful.Repo.Migrations.AlterUserDobField do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE users ALTER COLUMN dob TYPE DATE USING dob::date;"
  end

  def down do
    execute "ALTER TABLE users ALTER COLUMN dob TYPE VARCHAR(255);"
  end
end
