defmodule Mindful.Repo.Migrations.AddResponseDataFieldsToUserPverifyData do
  use Ecto.Migration

  def change do
    alter table(:user_pverify_data) do
      add(:individual_deductible_in_net, :string)
      add(:individual_deductible_remaining_in_net, :string)
      add(:individual_oop_remaining_in_net, :string)
      add(:eligibility_details, {:array, :map})
    end
  end
end
