defmodule MindfulWeb.OfficeView do
  use MindfulWeb, :view

  def addy_encoded(office) do
    suite = if office.suite, do: " " <> office.suite, else: ""

    addy =
      office.street <>
        suite <> ", " <> office.city <> ", " <> office.state_abbr <> " " <> office.zip

    # numbers are codepoints for unsafe map url encoding
    # https://developers.google.com/maps/url-encoding#common-characters-that-need-encoding
    URI.encode(addy, &(&1 not in [32, 34, 60, 62, 35, 37, 124]))
  end

  def fb_link(conn, office) do
    fb_snippet = "https://www.facebook.com/dialog/share?app_id=0000000&href="

    office_url =
      Routes.office_url(conn, :show, office.state_abbr, office) |> URI.encode_www_form()

    redirect_uri = "https://mindful.care" |> URI.encode_www_form()
    href = fb_snippet <> office_url <> "&redirect_uri=" <> redirect_uri

    "https://files.mindful.care/images/fb_icon.png"
    |> img_tag(alt: "share to Facebook")
    |> link(to: href, target: "_blank", title: "share on Facebook")
  end

  def tweet_link(conn, office) do
    twitter_snippet = "https://twitter.com/intent/tweet"
    tweet_text = "Mental health care in #{office.name}" |> URI.encode()
    hashtag = "&hashtags=mentalhealth,therapy,psychiatry,#{office.state_abbr}"

    office_url =
      Routes.office_url(conn, :show, office.state_abbr, office) |> URI.encode_www_form()

    href = twitter_snippet <> "?text=" <> tweet_text <> "&url=" <> office_url <> hashtag

    "https://files.mindful.care/images/twitter_icon.png"
    |> img_tag(alt: "share to twitter")
    |> link(to: href, target: "_blank", title: "share on Twitter")
  end

  def linkedin_link(conn, office) do
    linkedin_snippet = "https://www.linkedin.com/shareArticle?url="

    office_url =
      Routes.office_url(conn, :show, office.state_abbr, office) |> URI.encode_www_form()

    href = linkedin_snippet <> office_url

    "https://files.mindful.care/images/linkedin_icon.png"
    |> img_tag(alt: "share to linkedin")
    |> link(to: href, target: "_blank", title: "share on Linkedin")
  end

  def metatags(conn, office, :show) do
    # todo: get images for metatags uploaded to s3
    img_url = "https://files.mindful.care/images/metatagdefaultpic.jpg"

    %{
      "og:url" => Routes.office_url(conn, :show, office.state_abbr, office),
      "og:title" =>
        "Psychiatry and Therapy Treatments at Mindful Care #{office.name} #{String.upcase(office.state_abbr)}",
      "og:description" =>
        "#{office.name} #{office.city} Psychiatry | Mindful Care #{String.upcase(office.state_abbr)}",
      "og:image" => img_url,
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfuluc",
      "twitter:title" =>
        "Psychiatry and Therapy Treatments at Mindful Care #{office.name} #{String.upcase(office.state_abbr)}",
      "twitter:description" =>
        "#{office.name} #{office.city} Psychiatry | Mindful Care #{String.upcase(office.state_abbr)}",
      "twitter:image" => img_url
    }
  end
end
