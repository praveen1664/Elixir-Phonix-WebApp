defmodule MindfulWeb.PastSiteController do
  use MindfulWeb, :controller

  def redirect(conn, _params) do
    request_path = conn.request_path |> String.trim_trailing("/")

    route =
      cond do
        ### Locations
        request_path in [
          "/locations/new-york/psychiatrist-financial-district",
          "/locations/new-york/financial-district-psychiatrist",
          "/locations/new-york/psychiatrist-brooklyn"
        ] ->
          Routes.office_path(conn, :show, "new-york", "fort-greene")

        request_path in [
          "/locations/new-york/flatiron",
          "/locations/new-york/psychiatrist-flatiron",
          "/locations/new-york/flatiron-psychiatrist"
        ] ->
          Routes.office_path(conn, :show, "new-york", "flatiron-district")

        request_path in [
          "/locations/new-york/psychiatrist-white-plains",
          "/locations/new-york/white-plains-psychiatrist"
        ] ->
          Routes.office_path(conn, :show, "new-york", "white-plains")

        request_path in [
          "/locations/new-york/psychiatrist-west-hempstead",
          "/locations/new-york/west-hempstead-psychiatrist"
        ] ->
          Routes.office_path(conn, :show, "new-york", "west-hempstead")

        request_path == "/locations/illinois/psychiatrist-chicago-fulton-market" ->
          Routes.office_path(conn, :show, "illinois", "fulton-market")

        request_path in [
          "/locations/illinois/chicago-river-north-psychiatry",
          "/locations/illinois/chicago-lincoln-park-psychiatrist",
          "/locations/illinois/psychiatrist-chicago-river-north"
        ] ->
          Routes.office_path(conn, :show, "illinois", "near-north-side")

        request_path == "/locations/new-jersey/psychiatrist-hoboken" ->
          Routes.office_path(conn, :show, "new-jersey", "hoboken")

        request_path in [
          "/locations/new-york/longislandcity-lic-psychiatry",
          "/locations/new-york/queens-lic-psychiatry"
        ] ->
          Routes.office_path(conn, :show, "new-york", "long-island-city")

        request_path in [
          "/locations/new-york/grand-central-psychiatrist",
          "/locations/new-york/psychiatrist-grand-central"
        ] ->
          Routes.office_path(conn, :show, "new-york", "grand-central")

        request_path == "/locations/new-york/hicksville-ny-psychiatrist" ->
          Routes.office_path(conn, :show, "new-york", "hicksville")

        request_path == "/locations/new-york/melville-psychiatrist" ->
          Routes.state_path(conn, :index)

        request_path == "/welcome-chicago" ->
          Routes.state_path(conn, :show, "illinois")

        request_path == "/welcome-new-jersey" ->
          Routes.state_path(conn, :show, "new-jersey")

        request_path == "/locations/ny" ->
          Routes.state_path(conn, :show, "new-york")

        request_path == "/substance-use-counseling" ->
          Routes.page_path(conn, :substance_use)

        ### Staff
        request_path == "/our-staff" ->
          Routes.provider_path(conn, :index)

        request_path =~ "/our-staff/" ->
          [_, first_name, _last_name] = request_path |> String.split(["/our-staff/", "-"])
          Routes.provider_path(conn, :show, first_name)

        ### Blog
        request_path in [
          "/bipolar-disorder-5-interesting-facts-you-may-not-know",
          "/10-ways-to-manage-stress-and-anxiety-in-difficult-times"
        ] ->
          "/blog#{request_path}"

        # TODO: Fix blog paths for consistency with above
        request_path == "/power-of-responsibility-vs-blame" ->
          "/blog/the-power-of-responsibility-vs-blame"

        request_path == "/ways-group-therapy-can-make-you-feel-connected" ->
          "/blog/seven-ways-group-therapy-can-make-you-feel-connected-to-others"

        ### External
        request_path == "/admin" ->
          {:external, "https://mindfulcare.sharepoint.com/SitePages/Provider-Portal.aspx"}

        true ->
          "/"
      end

    if is_binary(route) do
      conn |> Phoenix.Controller.redirect(to: route) |> Plug.Conn.halt()
    else
      {:external, url} = route
      Phoenix.Controller.redirect(conn, external: url)
    end
  end
end
