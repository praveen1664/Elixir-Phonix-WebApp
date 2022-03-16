defmodule Mindful.Blog.Post do
  @moduledoc """
  Mindful.Blog.Post module
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias MindfulWeb.Helpers.Utils

  schema "posts" do
    field :pic_path, :string
    field :title, :string
    field :subtitle, :string
    field :body, :string
    field :published_at, :utc_datetime

    field :slug, :string

    timestamps()
  end

  @required_attrs ~w(pic_path title body)a
  @optional_attrs ~w(subtitle published_at)a

  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> add_slug()
    |> unsafe_validate_unique(:slug, Mindful.Repo)
    |> unique_constraint(:slug)
  end

  defp add_slug(changeset) do
    title = get_field(changeset, :title)

    if title do
      Utils.slugified_name(title)
      |> (&put_change(changeset, :slug, &1)).()
    else
      changeset
    end
  end

  defimpl Phoenix.Param, for: Mindful.Blog.Post do
    def to_param(%{slug: slug}) do
      "#{slug}"
    end
  end
end
