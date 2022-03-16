defmodule MindfulWeb.StateController do
  use MindfulWeb, :controller

  alias Mindful.Locations
  alias Mindful.Locations.State
  alias Mindful.Prospects
  alias Mindful.Prospects.Premarket

  def index(conn, _params) do
    states = Locations.list_states()

    render(conn, "index.html",
      states: states,
      page_title: "Mindful Care Locations | New York, New Jersey, Chicago Mental Health Clinic",
      page_description: "Mindful Care has locations in New York, New Jersey, and Illinois"
    )
  end

  def new(conn, _params) do
    changeset = Locations.change_state(%State{})
    render(conn, "new.html", changeset: changeset, state_abbrs: Utils.state_abbrs())
  end

  def create(conn, %{"state" => state_params}) do
    case Locations.create_state(new_state_params(state_params)) do
      {:ok, state} ->
        conn
        |> put_flash(:info, "State created successfully.")
        |> redirect(to: Routes.state_path(conn, :show, state))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, state_abbrs: Utils.state_abbrs())
    end
  end

  def show(conn, %{"slug" => slug}) do
    with %State{} = state <- Locations.get_state_by_slug(slug) do
      offices = Locations.list_offices_for_state(state)

      premarket_changeset =
        if state.coming_soon,
          do: nil,
          else: Prospects.change_premarket(%Premarket{state_abbr: slug})

      render(conn, "show.html",
        state: state,
        offices: offices,
        premarket_changeset: premarket_changeset,
        page_title: "#{state.name} Psychiatry and Mental Health Offices | Mindful Care",
        page_description: "Psychiatry and Therapy Treatments at Mindful Care #{state.name}",
        metatags: MindfulWeb.StateView.metatags(conn, state, :show)
      )
    else
      _ ->
        conn
        |> put_flash(:error, "State not found.")
        |> redirect(to: Routes.state_path(conn, :index))
    end
  end

  def edit(conn, %{"slug" => slug}) do
    with %State{} = state <- Locations.get_state_by_slug(slug) do
      changeset = Locations.edit_state_changeset(state)
      render(conn, "edit.html", state: state, changeset: changeset)
    else
      _ ->
        conn |> put_flash(:error, "State not found.") |> redirect(to: "/")
    end
  end

  def update(conn, %{"slug" => slug, "state" => state_params}) do
    with %State{} = state <- Locations.get_state_by_slug(slug) do
      case Locations.update_state(state, edit_state_params(state, state_params)) do
        {:ok, state} ->
          conn
          |> put_flash(:info, "State updated successfully.")
          |> redirect(to: Routes.state_path(conn, :show, state))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", state: state, changeset: changeset)
      end
    else
      _ ->
        conn |> put_flash(:error, "State not found.") |> redirect(to: "/")
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with %State{} = state <- Locations.get_state_by_slug(slug) do
      {:ok, _state} = Locations.delete_state(state)

      conn
      |> put_flash(:info, "State deleted successfully.")
      |> redirect(to: Routes.state_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "State not found.")
        |> redirect(to: Routes.state_path(conn, :index))
    end
  end

  defp new_state_params(state_params) do
    name = Utils.name_for_abbr(state_params["abbr"])

    if name do
      upload = state_params["state_image"]
      state_img_path = upload_image(upload, name) || state_params["image_path"]

      state_params
      |> Map.put("image_path", state_img_path)
      |> Map.put("name", Utils.name_for_abbr(state_params["abbr"]))
    else
      state_params
    end
  end

  defp edit_state_params(state, state_params) do
    upload = state_params["state_image"]

    if upload do
      state_img_path = upload_image(upload, state.name) || state_params["image_path"]

      state_params
      |> Map.put("image_path", state_img_path)
      |> Map.put("name", Utils.name_for_abbr(state_params["abbr"]))
    else
      state_params
    end
  end

  defp upload_image(%Plug.Upload{} = upload, name) do
    if upload.content_type in Utils.supported_image_formats() do
      file_extension = Path.extname(upload.filename)
      name = name |> String.downcase() |> String.replace(" ", "")
      filename = "/images/states/#{name}#{file_extension}"
      bucket = Application.get_env(:mindful, :bucket)[:name]
      opts = [content_type: upload.content_type, acl: :public_read]

      cropped_pic =
        upload.path |> Mogrify.open() |> Mogrify.resize_to_limit("1440x3000") |> Mogrify.save()

      {:ok, file_binary} = File.read(cropped_pic.path)

      {:ok, _request} =
        ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()

      {:ok, _request} =
        Utils.create_thumbnail(upload, name, file_extension, bucket, "states", opts)

      filename
    end
  end

  defp upload_image(_, _), do: nil
end
