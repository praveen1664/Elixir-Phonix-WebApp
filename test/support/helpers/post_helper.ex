defmodule Mindful.Test.Support.PostHelper do
  @moduledoc """
  Provides helpers for tests related to Posts
  """
  alias Mindful.Blog.Post
  alias Mindful.Factory

  @spec given_post(map) :: Post.t()
  def given_post(attrs \\ %{}) do
    post_attrs = fetch_keys(attrs)

    Factory.insert(:post, post_attrs)
  end

  ## Private Functions

  defp fetch_keys(attrs) do
    post_keys = Map.keys(%Post{})

    Map.take(attrs, post_keys)
  end
end
