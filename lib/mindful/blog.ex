defmodule Mindful.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query
  alias Mindful.Repo
  alias Mindful.Blog.Post

  @limit 6

  @doc """
  Returns the 6 latest posts.
  """
  def latest_posts(nil) do
    Post
    |> order_by(desc: :published_at)
    |> limit(@limit)
    |> Repo.all()
  end

  def latest_posts(offset) do
    res =
      Post
      |> order_by(desc: :published_at)
      |> limit(@limit)
      |> offset(^offset)
      |> Repo.all()

    if Enum.empty?(res), do: latest_posts(nil), else: res
  end

  def list_all_posts(), do: Post |> order_by(desc: :id) |> Repo.all()

  def get_post!(id), do: Repo.get!(Post, id)

  # TODO: Add test
  def get_post_by_slug(slug) when is_binary(slug),
    do: Repo.get_by(Post, slug: String.downcase(slug))

  def get_post_by_slug(_), do: nil

  def get_post_by_slug!(slug) do
    slug = if is_binary(slug), do: String.downcase(slug), else: slug
    Repo.get_by!(Post, slug: slug)
  end

  def create_post(attrs) do
    published_at = get_published_at(attrs["published_at"])
    attrs = Map.put(attrs, "published_at", published_at)

    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    published_at = get_published_at(post, attrs["published_at"])
    attrs = Map.put(attrs, "published_at", published_at)

    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post), do: Repo.delete(post)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  defp get_published_at(nil), do: DateTime.truncate(DateTime.utc_now(), :second)
  defp get_published_at(""), do: DateTime.truncate(DateTime.utc_now(), :second)

  defp get_published_at(date) do
    {:ok, dt, _} = DateTime.from_iso8601(date <> " 21:23:12+0100")
    dt
  end

  defp get_published_at(post, nil), do: post.published_at || get_published_at(nil)
  defp get_published_at(post, ""), do: post.published_at || get_published_at(nil)
  defp get_published_at(_post, date), do: get_published_at(date)
end
