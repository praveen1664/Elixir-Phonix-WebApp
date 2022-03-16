defmodule Mindful.BlogTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.PostHelper
  alias Mindful.Blog
  alias Mindful.Blog.Post
  alias MindfulWeb.Helpers.Utils

  @invalid_attrs %{
    "pic_path" => nil,
    "title" => nil,
    "subtitle" => "",
    "body" => nil,
    "slug" => "2nd Floor"
  }

  @update_attrs %{
    "title" => "updated title",
    "subtitle" => "updated sub title"
  }

  setup do
    published_at = DateTime.truncate(DateTime.utc_now(), :second)
    post = given_post(%{published_at: published_at})
    {:ok, post: post}
  end

  describe "create_post/1" do
    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{}} = Blog.create_post(valid_attributes())
    end
  end

  describe "update_post/2" do
    test "with valid data updates the post", %{post: post} do
      assert {:ok, %Post{slug: slug}} = Blog.update_post(post, @update_attrs)
      assert Utils.slugified_name(@update_attrs["title"]) == slug
    end

    test "with invalid data  returns a changeset error", %{post: post} do
      assert {:error, changeset} = Blog.update_post(post, @invalid_attrs)

      assert %{
               pic_path: ["can't be blank"],
               title: ["can't be blank"],
               body: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "get_post_by_slug/1" do
    test "with invalid  slug returns nil" do
      assert nil == Blog.get_post_by_slug(1)
    end

    test "with valid  slug returns post", %{post: post} do
      assert %Post{} = post0 = Blog.get_post_by_slug(post.slug)
      assert post0 == post
    end
  end

  describe "get_post!/1" do
    test "with valid id returns post", %{post: post} do
      assert %Post{} = post0 = Blog.get_post!(post.id)
      assert post0 == post
    end
  end

  describe "list_all_posts/0" do
    test "returns all posts", %{post: post} do
      assert [post0] = Blog.list_all_posts()
      assert post0 == post
    end
  end

  describe "latest_posts/1" do
    test "returns all posts ordered by published_at in descending order", %{
      post: post
    } do
      attr = Map.merge(valid_attributes(), %{"title" => "post 1", "published_at" => "2022-02-10"})
      assert {:ok, %Post{} = post1} = Blog.create_post(attr)
      attr = Map.merge(valid_attributes(), %{"title" => "post 2", "published_at" => "2022-01-21"})
      assert {:ok, %Post{} = post2} = Blog.create_post(attr)
      assert [post0, post01, post03] = Blog.latest_posts(nil)

      assert post0 == post
      assert post01 == post1
      assert post03 == post2
    end

    test "returns all posts with the given offset" do
      attr = Map.merge(valid_attributes(), %{"title" => "post 1", "published_at" => "2022-02-10"})
      assert {:ok, %Post{} = post1} = Blog.create_post(attr)
      attr = Map.merge(valid_attributes(), %{"title" => "post 2", "published_at" => "2022-01-21"})
      assert {:ok, %Post{} = post2} = Blog.create_post(attr)

      assert [post0, post01] = Blog.latest_posts(1)
      assert post0 == post1
      assert post01 == post2

      assert [post] = Blog.latest_posts(2)
      assert post == post2
    end
  end

  describe "delete_post/1" do
    test "deletes an existing post", %{post: post} do
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert nil == Blog.get_post_by_slug(post.slug)
    end
  end

  describe "change_post/2" do
    test "returns valid changeset with valid attributes" do
      published_at = DateTime.truncate(DateTime.utc_now(), :second)
      attr = Map.merge(valid_attributes(), %{"published_at" => published_at})
      assert %{valid?: true, changes: %{published_at: p_at}} = Blog.change_post(%Post{}, attr)
      assert published_at == p_at
    end

    test "returns changeset error with invalid attributes" do
      changeset = Blog.change_post(%Post{}, @invalid_attrs)

      assert %{
               pic_path: ["can't be blank"],
               title: ["can't be blank"],
               body: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  defp valid_attributes() do
    %{
      "pic_path" => "https://files.mindful.care/images/mindfulcareweblogo.svg",
      "title" => "Brooklyn",
      "subtitle" => "",
      "body" => "Fort Greene",
      "published_at" => "2022-02-21",
      "slug" => "2nd-floor"
    }
  end
end
