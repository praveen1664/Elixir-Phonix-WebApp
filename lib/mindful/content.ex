defmodule Mindful.Content do
  @moduledoc """
  The Content context for handling editable site content.
  """

  import Ecto.Query
  alias Mindful.Repo
  alias Mindful.Content.{MarkdownBlob, TeamMember}

  def preload_markdown_blob(model), do: Repo.preload(model, :markdown_blob)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking new markdown blob changes.
  """
  def new_change_markdown(%MarkdownBlob{} = md, %Mindful.Locations.Office{id: office_id}) do
    MarkdownBlob.create_changeset(%{md | office_id: office_id})
  end

  @doc """
  Creates a markdown blob.
  """
  def create_md_blob(attrs) do
    %MarkdownBlob{}
    |> MarkdownBlob.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edit markdown blob changes
  for an office.
  """
  def edit_change_markdown(%MarkdownBlob{} = markdown_blob, attrs \\ %{}) do
    MarkdownBlob.edit_changeset(markdown_blob, attrs)
  end

  @doc """
  Updates a markdown blob.
  """
  def update_md_blob(%MarkdownBlob{} = markdown_blob, attrs) do
    markdown_blob
    |> MarkdownBlob.edit_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a markdown blob.
  """
  def delete_md_blob(%MarkdownBlob{} = markdown_blob) do
    Repo.delete(markdown_blob)
  end

  def list_team_members do
    TeamMember
    |> order_by(asc: :rank)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  def get_team_member!(id), do: Repo.get!(TeamMember, id)

  def change_team_member(%TeamMember{} = team_member, attrs \\ %{}) do
    TeamMember.changeset(team_member, attrs)
  end

  def create_team_member(attrs) do
    %TeamMember{}
    |> TeamMember.changeset(attrs)
    |> Repo.insert()
  end

  def update_team_member(%TeamMember{} = team_member, attrs) do
    team_member
    |> TeamMember.changeset(attrs)
    |> Repo.update()
  end

  def delete_team_member(%TeamMember{} = team_member), do: Repo.delete(team_member)
end
