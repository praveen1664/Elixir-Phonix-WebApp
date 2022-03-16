defmodule Mindful.Repo.Migrations.AddPlanCoverageSummaryToUserPverifyData do
  use Ecto.Migration

  def change do
    alter table(:user_pverify_data) do
      add(:is_hmo_plan, :boolean, default: false)
      add(:plan_coverage_summary, :map)
      add(:other_payer_info, :map)
      add(:co_insurance_in_net, :string)
      add(:co_pay_in_net, :string)
    end
  end
end
