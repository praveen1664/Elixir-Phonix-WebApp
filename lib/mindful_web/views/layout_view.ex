defmodule MindfulWeb.LayoutView do
  use MindfulWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def page_title(%{page_title: page_title}), do: content_tag(:title, page_title)

  def page_title(_assigns),
    do: content_tag(:title, "Mindful Care | Same Day Psychiatry Treatment")

  def page_description(%{page_description: description}),
    do: raw("\t<meta name=\"description\" content=\"#{description}\">")

  def page_description(_assigns) do
    raw(
      "\t<meta name=\"description\" content=\"Accessible and affordable mental health services.\">"
    )
  end

  def metatags(%{metatags: metatags}) when is_map(metatags) do
    for({key, value} <- metatags) do
      raw("\t<meta property=\"#{key}\" content=\"#{value}\">\n")
    end
  end

  def metatags(_assigns), do: nil
end
