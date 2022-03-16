defmodule Mindful.Repo.Migrations.AddPverifyEligibilityVerifiedToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:pverify_eligibility_verified, :boolean, default: false)
    end
  end
end
