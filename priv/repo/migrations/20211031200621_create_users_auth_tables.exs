defmodule Mindful.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :first_name, :string
      add :last_name, :string
      add :superadmin, :boolean, default: false
      add :roles, {:array, :string}, default: []
      add :stripe_id, :string
      add :payment_method_id, :string
      add :cc_last_4, :string
      add :image_path, :string
      add :phone, :string
      add :about, :text
      add :state_abbr, :string
      add :drchrono_oauth_token, :string
      add :drchrono_oauth_refresh_token, :string
      add :drchrono_oauth_expires_at, :naive_datetime
      add :drchrono_id, :integer

      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
