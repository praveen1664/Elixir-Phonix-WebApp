defmodule Mindful.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :name, :string
      add :job_title, :string
      add :image_path, :string
      add :rank, :integer

      timestamps()
    end
  end
end
