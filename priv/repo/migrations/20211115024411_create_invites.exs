defmodule Mindful.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :reason, :string
      add :to, :citext, null: false
      add :created_by, :citext, null: false

      timestamps()
    end
  end
end
