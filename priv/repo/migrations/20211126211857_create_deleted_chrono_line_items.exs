defmodule Mindful.Repo.Migrations.CreateDeletedChronoLineItems do
  use Ecto.Migration

  def change do
    create table(:deleted_chrono_line_items) do
      add :appointment, :integer
      add :balance_total, :string
      add :code, :string
      add :service_date, :string
    end
  end
end
