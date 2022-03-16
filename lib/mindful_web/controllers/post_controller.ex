defmodule MindfulWeb.PostController do
  use MindfulWeb, :controller

  alias Mindful.Blog
  alias Mindful.Blog.Post

  def index(conn, params) do
    page_number = if params["p"], do: String.to_integer(params["p"])
    posts = Blog.latest_posts(calc_offset(page_number))

    newer_link =
      if page_number && page_number != 0 do
        Routes.post_path(conn, :index, %{p: page_number - 1})
      end

    older_link =
      if length(posts) >= 6 do
        page_number = if page_number, do: page_number, else: 0
        Routes.post_path(conn, :index, %{p: page_number + 1})
      end

    render(conn, "index.html",
      posts: posts,
      newer_link: newer_link,
      older_link: older_link,
      page_title: "Blog | Mindful Care",
      page_description:
        "Mindful Care is committed to providing quality mental health and psychiatric materials to our visitors."
    )
  end

  def edit_index(conn, _params) do
    posts = Blog.list_all_posts()
    render(conn, "edit_index.html", posts: posts, page_title: "Edit Blog Posts")
  end

  def new(conn, _params) do
    changeset = Blog.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(add_pic_path_to_params(post_params)) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    with %Post{} = post <- Blog.get_post_by_slug(slug) do
      render(conn, "show.html",
        post: post,
        page_title: post.title,
        page_description: post.title,
        metatags: MindfulWeb.PostView.metatags(conn, post, :show)
      )
    else
      _ ->
        conn
        |> put_flash(:error, "Post not found.")
        |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  def edit(conn, %{"slug" => slug}) do
    with %Post{} = post <- Blog.get_post_by_slug(slug) do
      changeset = Blog.change_post(post)
      render(conn, "edit.html", post: post, changeset: changeset)
    else
      _ ->
        conn |> put_flash(:error, "Post not found.") |> redirect(to: "/")
    end
  end

  def update(conn, %{"slug" => slug, "post" => post_params}) do
    with %Post{} = post <- Blog.get_post_by_slug(slug) do
      case Blog.update_post(post, add_pic_path_to_params(post_params)) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    else
      _ ->
        conn |> put_flash(:error, "Post not found.") |> redirect(to: "/")
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with %Post{} = post <- Blog.get_post_by_slug(slug) do
      {:ok, _post} = Blog.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Post not found.")
        |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  defp add_pic_path_to_params(post_params) do
    upload = post_params["post_image"]

    if upload do
      post_img_path = upload_image(upload) || post_params["pic_path"]
      post_params |> Map.put("pic_path", post_img_path)
    else
      post_params
    end
  end

  defp upload_image(%Plug.Upload{} = upload) do
    if upload.content_type in Utils.supported_image_formats() do
      file_extension = Path.extname(upload.filename)
      # generate a random string to serve as the name of the image
      name = for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>
      filename = "/images/posts/#{name}#{file_extension}"
      bucket = Application.get_env(:mindful, :bucket)[:name]
      opts = [content_type: upload.content_type, acl: :public_read]

      cropped_pic =
        upload.path |> Mogrify.open() |> Mogrify.resize_to_limit("620x1100") |> Mogrify.save()

      {:ok, file_binary} = File.read(cropped_pic.path)

      {:ok, _request} =
        ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()

      {:ok, _request} =
        Utils.create_thumbnail(upload, name, file_extension, bucket, "posts", opts)

      filename
    end
  end

  defp upload_image(_), do: nil

  defp calc_offset(nil), do: nil

  defp calc_offset(page_number) do
    # since we are showing 6 posts per page, multiply the current page number
    # by 6 to deduce the offset when querying for more posts
    page_number * 6
  end
end
