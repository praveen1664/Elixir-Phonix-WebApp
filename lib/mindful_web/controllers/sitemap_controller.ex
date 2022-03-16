defmodule MindfulWeb.SitemapController do
  use MindfulWeb, :controller

  plug :put_layout, false

  def index(conn, _params) do
    posts = Mindful.Blog.list_all_posts()
    providers = Mindful.Clinicians.list_providers()
    states = Mindful.Locations.list_states()
    offices = Mindful.Locations.list_offices()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", posts: posts, providers: providers, offices: offices, states: states)
  end
end
