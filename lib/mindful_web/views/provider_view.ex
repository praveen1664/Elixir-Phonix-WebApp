defmodule MindfulWeb.ProviderView do
  use MindfulWeb, :view

  def metatags(conn, provider, :show) do
    %{
      "og:url" => Routes.provider_url(conn, :show, provider),
      "og:title" => "#{VH.formalize_name(provider)} #{provider.job_title}",
      "og:description" => "Get mental health care with #{VH.formalize_name(provider)}.",
      "og:image" => provider.image_path,
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfuluc",
      "twitter:title" => "#{VH.formalize_name(provider)} #{provider.job_title}",
      "twitter:description" => "Get mental health care with #{VH.formalize_name(provider)}}.",
      "twitter:image" => provider.image_path
    }
  end
end
