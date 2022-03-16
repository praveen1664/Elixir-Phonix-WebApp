defmodule Mindful.Repo.Migrations.CreateUserPverifyData do
  use Ecto.Migration

  def change do
    create table(:user_pverify_data) do
      add(:payer_code, :string)
      add(:provider_name, :string)
      add(:provider_npi, :string)
      add(:subscriber_member_id, :string)
      add(:is_subscriber_patient, :boolean, default: true)
      add(:dos_start_date, :string)
      add(:dos_end_date, :string)
      add(:insurance_card_front, :string)
      add(:insurance_card_back, :string)

      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create unique_index(:user_pverify_data, [:user_id])
  end
end
