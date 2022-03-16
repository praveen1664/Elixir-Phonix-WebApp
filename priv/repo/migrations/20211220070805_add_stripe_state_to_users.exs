defmodule Mindful.Repo.Migrations.AddStripeStateToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :stripe_state, :string
    end
  end
end
