defmodule MindfulWeb.OfficeController do
  use MindfulWeb, :controller

  alias Mindful.Content
  alias Mindful.Content.MarkdownBlob
  alias Mindful.Locations
  alias Mindful.Locations.Office

  # office actions
  def new(conn, %{"slug" => state_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    changeset = Locations.new_change_office(%Office{})
    render(conn, "new.html", state: state, changeset: changeset)
  end

  def create(conn, %{"slug" => state_slug, "office" => office_params}) do
    state = Locations.get_state_by_slug!(state_slug)
    office_params = Map.put(office_params, "state_abbr", state.abbr)

    case Locations.create_office(office_params) do
      {:ok, office} ->
        conn
        |> put_flash(:info, "Office created successfully.")
        |> redirect(to: Routes.office_path(conn, :show, state, office))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", state: state, changeset: changeset)
    end
  end

  def show(conn, %{"slug" => state_slug, "o_slug" => office_slug}) when is_binary(office_slug) do
    state = Locations.get_state_by_slug!(state_slug)

    slug = String.downcase(office_slug)
    # changed slug to include "-psychiatry" to the end and google cached the old slugs
    if String.contains?(slug, "psychiatry") do
      office = slug |> Locations.get_office_by_slug!() |> Content.preload_markdown_blob()
      reviews = Locations.list_reviews_for_location(office.google_location_id)

      render(conn, "show.html",
        office: office,
        state: state,
        reviews: reviews,
        page_title:
          "Psychiatry and Therapy Treatments at Mindful Care #{office.name} #{String.upcase(state.abbr)}",
        page_description: "#{office.name} #{office.city} Psychiatry | Mindful Care #{state.name}",
        metatags: MindfulWeb.OfficeView.metatags(conn, office, :show)
      )
    else
      new_o_slug = slug <> "-psychiatry"
      redirect(conn, to: Routes.office_path(conn, :show, state, new_o_slug))
    end
  rescue
    Ecto.NoResultsError -> not_found(conn)
  end

  def edit(conn, %{"slug" => state_slug, "o_slug" => office_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = Locations.get_office_by_slug!(office_slug)
    changeset = Locations.edit_change_office(office)
    render(conn, "edit.html", office: office, state: state, changeset: changeset)
  end

  def update(conn, %{"slug" => state_slug, "o_slug" => office_slug, "office" => office_params}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = Locations.get_office_by_slug!(office_slug)

    case Locations.update_office(office, office_params) do
      {:ok, office} ->
        conn
        |> put_flash(:info, "Office updated successfully.")
        |> redirect(to: Routes.office_path(conn, :show, state, office))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", office: office, state: state, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => state_slug, "o_slug" => office_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = Locations.get_office_by_slug!(office_slug)

    {:ok, _office} = Locations.delete_office(office)

    conn
    |> put_flash(:info, office.name <> " office deleted successfully.")
    |> redirect(to: Routes.state_path(conn, :show, state))
  end

  # office markdown blob actions
  def new_markdown(conn, %{"slug" => state_slug, "o_slug" => office_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = office_slug |> Locations.get_office_by_slug!() |> Content.preload_markdown_blob()

    if office.markdown_blob do
      redirect(conn, to: Routes.office_path(conn, :edit_markdown, state, office))
    else
      changeset = Content.new_change_markdown(%MarkdownBlob{}, office)
      render(conn, "new_markdown.html", state: state, office: office, changeset: changeset)
    end
  end

  def create_markdown(conn, %{"slug" => state_slug, "o_slug" => office_slug, "md_blob" => params}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = Locations.get_office_by_slug!(office_slug)
    params = Map.put(params, "office_id", office.id)

    case Content.create_md_blob(params) do
      {:ok, _md_blob} ->
        conn
        |> put_flash(:info, "Page content added.")
        |> redirect(to: Routes.office_path(conn, :show, state, office))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_markdown.html", state: state, office: office, changeset: changeset)
    end
  end

  def edit_markdown(conn, %{"slug" => state_slug, "o_slug" => office_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = office_slug |> Locations.get_office_by_slug!() |> Content.preload_markdown_blob()
    changeset = Content.edit_change_markdown(office.markdown_blob)
    render(conn, "edit_markdown.html", office: office, state: state, changeset: changeset)
  end

  def update_markdown(conn, %{"slug" => state_slug, "o_slug" => office_slug, "md_blob" => params}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = office_slug |> Locations.get_office_by_slug!() |> Content.preload_markdown_blob()

    case Content.update_md_blob(office.markdown_blob, params) do
      {:ok, _md_blob} ->
        conn
        |> put_flash(:info, "Page content updated.")
        |> redirect(to: Routes.office_path(conn, :show, state, office))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit_markdown.html", office: office, state: state, changeset: changeset)
    end
  end

  def delete_markdown(conn, %{"slug" => state_slug, "o_slug" => office_slug}) do
    state = Locations.get_state_by_slug!(state_slug)
    office = office_slug |> Locations.get_office_by_slug!() |> Content.preload_markdown_blob()
    {:ok, _md_blob} = Content.delete_md_blob(office.markdown_blob)

    conn
    |> put_flash(:info, "Page content removed.")
    |> redirect(to: Routes.office_path(conn, :show, state, office))
  end

  def not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(MindfulWeb.ErrorView)
    |> render(:"404")
    |> halt()
  end
end
