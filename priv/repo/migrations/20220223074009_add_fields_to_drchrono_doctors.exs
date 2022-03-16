defmodule Mindful.Repo.Migrations.AddFieldsToDrchronoDoctors do
  use Ecto.Migration

  def up do
    alter table(:drchrono_doctors) do
      add :office_phone, :string
      add :profile_picture, :text
      add :suffix, :string
      add :timezone, :string
    end
  end

  def down do
    alter table(:drchrono_doctors) do
      remove :office_phone
      remove :profile_picture
      remove :suffix
      remove :timezone
    end
  end
end
