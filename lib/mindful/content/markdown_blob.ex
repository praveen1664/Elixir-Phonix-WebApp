defmodule Mindful.Content.MarkdownBlob do
  @moduledoc """
  Mindful.Content.MarkdownBlob module
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "markdown_blobs" do
    field :body, :string

    belongs_to :office, Mindful.Locations.Office

    timestamps()
  end

  @attrs ~w(body office_id)a

  def create_changeset(markdown_blob, attrs \\ %{}) do
    markdown_blob
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> unique_constraint(:office_id, message: "click cancel and try again")
  end

  def edit_changeset(markdown_blob, attrs) do
    markdown_blob |> cast(attrs, [:body]) |> validate_required([:body])
  end
end
