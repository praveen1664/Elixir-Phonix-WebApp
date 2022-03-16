defmodule Mindful.Utilities do
  @moduledoc """
  The Utilities context.
  """

  alias Mindful.Repo
  alias Mindful.Utilities.DeletedChronoLineItem

  @doc """
  Save the recently deleted Dr Chrono line item to the database.
  """
  def create_deleted_line_item(attrs \\ %{}) do
    %DeletedChronoLineItem{}
    |> DeletedChronoLineItem.changeset(attrs)
    |> Repo.insert()
  end

  def list_deleted_chrono_line_items, do: Repo.all(DeletedChronoLineItem)
end
