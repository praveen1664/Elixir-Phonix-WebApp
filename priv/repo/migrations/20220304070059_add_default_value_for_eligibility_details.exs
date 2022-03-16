defmodule Mindful.Repo.Migrations.AddDefaultValueForEligibilityDetails do
  use Ecto.Migration

  def change do
    alter table(:user_pverify_data) do
      modify :eligibility_details, {:array, :map}, default: []
    end
  end
end
