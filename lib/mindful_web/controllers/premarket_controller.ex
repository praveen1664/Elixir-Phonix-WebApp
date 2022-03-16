defmodule MindfulWeb.PremarketController do
  use MindfulWeb, :controller

  alias Mindful.Prospects
  alias Mindful.Prospects.Premarket

  def new(conn, %{"state" => state_abbr}) do
    changeset = Prospects.change_premarket(%Premarket{state_abbr: state_abbr})
    render(conn, "new.html", changeset: changeset, state_abbr: state_abbr)
  end

  def new(conn, _), do: redirect(conn, to: Routes.state_path(conn, :index))

  def create(conn, params) do
    case Prospects.create_premarket(params) do
      {:ok, premarket} ->
        conn
        |> put_flash(
          :info,
          "👍 We'll let you know when we open in #{String.upcase(premarket.state_abbr)}."
        )
        |> redirect(to: "/")

      {:error, _} ->
        redirect(conn, to: Routes.state_path(conn, :index))
    end
  end
end
