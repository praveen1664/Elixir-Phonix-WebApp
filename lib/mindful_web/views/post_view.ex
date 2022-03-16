defmodule MindfulWeb.PostView do
  use MindfulWeb, :view

  def metatags(conn, post, :show) do
    %{
      "og:url" => Routes.post_url(conn, :show, post),
      "og:title" => post.title,
      "og:description" => post.subtitle || "Mental health and wellness | Mindful Care",
      "og:image" => VH.uploaded_img_url(post.pic_path),
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => post.title,
      "twitter:description" => post.subtitle || "Mental health and wellness | Mindful Care",
      "twitter:image" => VH.uploaded_img_url(post.pic_path)
    }
  end
end
