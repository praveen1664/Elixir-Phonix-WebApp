defmodule Mindful.Blog.PostTest do
  use Mindful.DataCase, async: true

  import Mindful.Test.Support.PostHelper
  alias Ecto.Changeset
  alias Mindful.Blog.Post

  @invalid_attrs %{
    pic_path: nil,
    title: nil,
    subtitle: "",
    body: nil,
    published_at: "41 Flatbush Ave",
    slug: "2nd Floor"
  }

  setup do
    published_at = DateTime.truncate(DateTime.utc_now(), :second)
    post = given_post(%{published_at: published_at})
    {:ok, post: post}
  end

  describe "changeset/2" do
    test "fails with invalid attrs" do
      assert %{valid?: false} = changeset = Post.changeset(%Post{}, @invalid_attrs)

      assert %{
               pic_path: ["can't be blank"],
               title: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "slugify title", %{post: post} do
      changeset = Post.changeset(post, %{title: "slugified title"})
      assert Changeset.get_field(changeset, :slug) == "slugified-title"

      changeset = Post.changeset(post, %{title: "1-Slugified Title Tty"})
      assert Changeset.get_field(changeset, :slug) == "1-slugified-title-tty"
    end

    test "title slug must be unique" do
      {:ok, _schema} =
        %Post{}
        |> Post.changeset(valid_attributes())
        |> Repo.insert()

      {:error, changeset} =
        %Post{}
        |> Post.changeset(valid_attributes())
        |> Repo.insert()

      assert %{slug: ["has already been taken"]} = errors_on(changeset)
    end

    test "slugify when update post", %{post: post} do
      {:ok, updated_post} =
        post
        |> Post.changeset(%{title: "updated title"})
        |> Repo.update()

      assert updated_post.slug == "updated-title"
    end
  end

  defp valid_attributes() do
    published_at = DateTime.truncate(DateTime.utc_now(), :second)

    %{
      "pic_path" => "https://files.mindful.care/images/mindfulcareweblogo.svg",
      "title" => "Brooklyn",
      "subtitle" => "",
      "body" => "Fort Greene",
      "published_at" => published_at,
      "slug" => "2nd-floor"
    }
  end
end
