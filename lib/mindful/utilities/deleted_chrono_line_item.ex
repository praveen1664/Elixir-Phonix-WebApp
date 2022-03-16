defmodule Mindful.Utilities.DeletedChronoLineItem do
  @moduledoc """
  Mindful.Utilities.DeletedChronoLineItem module
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "deleted_chrono_line_items" do
    field :appointment, :integer
    field :balance_total, :string
    field :code, :string
    field :service_date, :string
  end

  @attrs ~w(balance_total code service_date appointment)a

  def changeset(line_item, attrs) do
    line_item
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
