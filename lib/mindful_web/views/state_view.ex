defmodule MindfulWeb.StateView do
  use MindfulWeb, :view

  def fb_link(conn, state) do
    fb_snippet = "https://www.facebook.com/dialog/share?app_id=0000000&href="
    state_url = Routes.state_url(conn, :show, state) |> URI.encode_www_form()
    redirect_uri = "https://mindful.care" |> URI.encode_www_form()
    href = fb_snippet <> state_url <> "&redirect_uri=" <> redirect_uri

    "https://files.mindful.care/images/fb_icon.png"
    |> img_tag(alt: "share to Facebook")
    |> link(to: href, target: "_blank", title: "share on Facebook")
  end

  def tweet_link(conn, state) do
    twitter_snippet = "https://twitter.com/intent/tweet"
    tweet_text = "Mental health care in #{state.name}" |> URI.encode()
    hashtag = "&hashtags=mentalhealth,therapy,psychiatry,#{state.name}"
    state_url = Routes.state_url(conn, :show, state) |> URI.encode_www_form()
    href = twitter_snippet <> "?text=" <> tweet_text <> "&url=" <> state_url <> hashtag

    "https://files.mindful.care/images/twitter_icon.png"
    |> img_tag(alt: "share to twitter")
    |> link(to: href, target: "_blank", title: "share on Twitter")
  end

  def linkedin_link(conn, state) do
    linkedin_snippet = "https://www.linkedin.com/shareArticle?url="
    state_url = Routes.state_url(conn, :show, state) |> URI.encode_www_form()
    href = linkedin_snippet <> state_url

    "https://files.mindful.care/images/linkedin_icon.png"
    |> img_tag(alt: "share to linkedin")
    |> link(to: href, target: "_blank", title: "share on Linkedin")
  end

  def metatags(conn, state, :show) do
    # todo: get images for metatags uploaded to s3
    img_url = "https://files.mindful.care/images/metatagdefaultpic.jpg"

    %{
      "og:url" => Routes.state_url(conn, :show, state),
      "og:title" => "#{state.name} Psychiatry and Mental Health Offices | Mindful Care",
      "og:description" => "Psychiatry and Therapy Treatments at Mindful Care #{state.name}.",
      "og:image" => img_url,
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfuluc",
      "twitter:title" => "#{state.name} Psychiatry and Mental Health Offices | Mindful Care",
      "twitter:description" => "Psychiatry and Therapy Treatments at Mindful Care #{state.name}.",
      "twitter:image" => img_url
    }
  end
end
