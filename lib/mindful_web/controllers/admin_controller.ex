defmodule MindfulWeb.AdminController do
  use MindfulWeb, :controller

  def index(conn, _) do
    conn
    |> assign(:page_title, "Admin | Mindful Care")
    |> render("index.html")
  end

  def new_reviews(conn, %{"access_token" => access_token}) do
    MindfulWeb.GoogleBusinessAdapter.refresh_reviews(access_token)

    conn
    |> put_flash(:success, "Google review data has been refreshed!")
    |> redirect(to: Routes.admin_path(conn, :index))
  end

  def new_reviews(conn, _) do
    render(conn, "new_reviews.html",
      page_title: "Refresh Google Reviews | Mindful Care",
      client_id: Application.get_env(:mindful, :google_mybusiness)[:client_id]
    )
  end

  def google_reviews(conn, _) do
    render(conn, "google_reviews.html",
      page_title: "Refresh Google Reviews | Mindful Care",
      locations: Mindful.Locations.list_google_locations()
    )
  end
end
