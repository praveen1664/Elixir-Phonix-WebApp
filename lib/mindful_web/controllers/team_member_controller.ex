defmodule MindfulWeb.TeamMemberController do
  use MindfulWeb, :controller

  alias Mindful.Content
  alias Mindful.Content.TeamMember

  def index(conn, _params) do
    team_members = Content.list_team_members()

    render(conn, "index.html",
      team_members: team_members,
      page_description: "Mindful Care's Leadership Team"
    )
  end

  def new(conn, _params) do
    changeset = Content.change_team_member(%TeamMember{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team_member" => team_member_params}) do
    team_member_params = add_upload_to_params(team_member_params)

    case Content.create_team_member(team_member_params) do
      {:ok, _team_member} ->
        conn
        |> put_flash(:info, "Team member created successfully.")
        |> redirect(to: Routes.team_member_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    team_member = Content.get_team_member!(id)
    changeset = Content.change_team_member(team_member)
    render(conn, "edit.html", team_member: team_member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team_member" => team_member_params}) do
    team_member = Content.get_team_member!(id)
    team_member_params = add_upload_to_params(team_member_params)

    case Content.update_team_member(team_member, team_member_params) do
      {:ok, _team_member} ->
        conn
        |> put_flash(:info, "Team member updated.")
        |> redirect(to: Routes.team_member_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", team_member: team_member, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team_member = Content.get_team_member!(id)
    {:ok, _team_member} = Content.delete_team_member(team_member)

    conn
    |> put_flash(:info, "Team member deleted successfully.")
    |> redirect(to: Routes.team_member_path(conn, :index))
  end

  def add_upload_to_params(team_member_params) do
    name = team_member_params["name"]

    if name do
      # generate a random string to serve as the slug of the image
      pic_slug = for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>
      upload = team_member_params["team_member_image"]
      team_member_img_path = upload_image(upload, pic_slug) || team_member_params["image_path"]
      team_member_params |> Map.put("image_path", team_member_img_path)
    else
      team_member_params
    end
  end

  defp upload_image(%Plug.Upload{} = upload, name) do
    if upload.content_type in Utils.supported_image_formats() do
      file_extension = Path.extname(upload.filename)
      name = name |> String.downcase() |> String.replace(" ", "")
      filename = "/images/team_members/#{name}#{file_extension}"
      bucket = Application.get_env(:mindful, :bucket)[:name]
      opts = [content_type: upload.content_type, acl: :public_read]

      cropped_pic =
        upload.path
        |> Mogrify.open()
        |> Mogrify.gravity("Center")
        |> Mogrify.resize_to_fill("200x200")
        |> Mogrify.save()

      {:ok, file_binary} = File.read(cropped_pic.path)

      {:ok, _request} =
        ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()

      filename
    end
  end

  defp upload_image(_, _), do: nil
end
