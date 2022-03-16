defmodule MindfulWeb.ProviderController do
  use MindfulWeb, :controller

  alias Mindful.Clinicians
  alias Mindful.Clinicians.Provider
  alias MindfulWeb.Helpers.Utils

  def index(conn, _params) do
    providers = Clinicians.list_providers()
    render(conn, "index.html", providers: providers, page_description: "Mindful Care's Providers")
  end

  def new(conn, _params) do
    changeset = Clinicians.change_provider(%Provider{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"provider" => provider_params}) do
    provider_params = new_provider_params(provider_params)

    case Clinicians.create_provider(provider_params) do
      {:ok, provider} ->
        conn
        |> put_flash(:info, "Provider created successfully.")
        |> redirect(to: Routes.provider_path(conn, :show, provider))

      {:error, %Ecto.Changeset{} = changeset} ->
        # if slug error, try adding a random digit and creating again
        if Keyword.has_key?(changeset.errors, :slug) and length(changeset.errors) == 1 do
          slug_rand = changeset.changes.slug <> Integer.to_string(Enum.random(0..100))
          provider_params = Map.put(provider_params, "slug", slug_rand)

          case Clinicians.create_provider(provider_params) do
            {:ok, provider} ->
              conn
              |> put_flash(:info, "Provider created successfully.")
              |> redirect(to: Routes.provider_path(conn, :show, provider))

            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "new.html", changeset: changeset)
          end
        else
          render(conn, "new.html", changeset: changeset)
        end
    end
  end

  def show(conn, %{"slug" => slug}) do
    with %Provider{} = provider <- Clinicians.get_provider_by_slug(slug) do
      render(conn, "show.html",
        provider: provider,
        page_title: "#{formal_name(provider)} #{provider.job_title}",
        page_description: "Mental health care professionals at Mindful Care",
        metatags: MindfulWeb.ProviderView.metatags(conn, provider, :show)
      )
    else
      nil ->
        conn
        |> put_flash(:error, "Provider not found.")
        |> redirect(to: Routes.provider_path(conn, :index))
    end
  end

  def edit(conn, %{"slug" => slug}) do
    if provider = Clinicians.get_provider_by_slug(slug) do
      changeset = Clinicians.edit_provider_changeset(provider)
      render(conn, "edit.html", provider: provider, changeset: changeset)
    else
      conn |> put_flash(:error, "Provider not found.") |> redirect(to: "/")
    end
  end

  def update(conn, %{"slug" => slug, "provider" => provider_params}) do
    if provider = Clinicians.get_provider_by_slug(slug) do
      provider_params = edit_provider_params(provider_params)

      case Clinicians.update_provider(provider, provider_params) do
        {:ok, provider} ->
          conn
          |> put_flash(:info, "Provider updated.")
          |> redirect(to: Routes.provider_path(conn, :show, provider))

        {:error, %Ecto.Changeset{} = changeset} ->
          # if slug error, try adding a random digit and creating again
          if Keyword.has_key?(changeset.errors, :slug) and length(changeset.errors) == 1 do
            slug_rand = changeset.changes.slug <> Integer.to_string(Enum.random(0..100))
            provider_params = Map.put(provider_params, "slug", slug_rand)

            case Clinicians.update_provider(provider, provider_params) do
              {:ok, provider} ->
                conn
                |> put_flash(:info, "Provider updated.")
                |> redirect(to: Routes.provider_path(conn, :show, provider))

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "edit.html", provider: provider, changeset: changeset)
            end
          else
            render(conn, "edit.html", provider: provider, changeset: changeset)
          end
      end
    else
      conn |> put_flash(:error, "Provider not found.") |> redirect(to: "/")
    end
  end

  def edit_details(conn, %{"slug" => slug}) do
    if provider = Clinicians.get_provider_by_slug(slug) do
      changeset = Clinicians.edit_provider_details_changeset(provider)
      render(conn, "edit_details.html", provider: provider, changeset: changeset)
    else
      conn |> put_flash(:error, "Provider not found.") |> redirect(to: "/")
    end
  end

  def update_details(conn, %{"slug" => slug, "provider" => provider_params}) do
    if provider = Clinicians.get_provider_by_slug(slug) do
      case Clinicians.update_provider_details(provider, provider_params) do
        {:ok, provider} ->
          conn
          |> put_flash(:info, "Provider details updated.")
          |> redirect(to: Routes.provider_path(conn, :show, provider))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit_details.html", provider: provider, changeset: changeset)
      end
    else
      conn |> put_flash(:error, "Provider not found.") |> redirect(to: "/")
    end
  end

  def delete(conn, %{"slug" => slug}) do
    if provider = Clinicians.get_provider_by_slug(slug) do
      {:ok, _provider} = Clinicians.delete_provider(provider)

      conn
      |> put_flash(:info, "Provider deleted successfully.")
      |> redirect(to: Routes.provider_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Provider not found.")
      |> redirect(to: Routes.provider_path(conn, :index))
    end
  end

  defp formal_name(provider) do
    MindfulWeb.ViewHelpers.formalize_name(provider)
  end

  defp new_provider_params(provider_params) do
    first_name = provider_params["first_name"]
    last_name = provider_params["last_name"]

    if first_name && last_name do
      pic_slug = slugify_image_name(first_name, last_name)
      upload = provider_params["provider_image"]
      provider_img_path = upload_image(upload, pic_slug) || provider_params["image_path"]
      provider_params |> Map.put("image_path", provider_img_path)
    else
      provider_params
    end
  end

  defp edit_provider_params(provider_params) do
    if upload = provider_params["provider_image"] do
      pic_slug = slugify_image_name(provider_params["first_name"], provider_params["last_name"])
      provider_img_path = upload_image(upload, pic_slug) || provider_params["image_path"]
      Map.put(provider_params, "image_path", provider_img_path)
    else
      provider_params
    end
  end

  defp upload_image(%Plug.Upload{} = upload, name) do
    if upload.content_type in Utils.supported_image_formats() do
      file_extension = Path.extname(upload.filename)
      name = name |> String.downcase() |> String.replace(" ", "")
      filename = "/images/providers/#{name}#{file_extension}"
      bucket = Application.get_env(:mindful, :bucket)[:name]
      opts = [content_type: upload.content_type, acl: :public_read]

      cropped_pic =
        upload.path |> Mogrify.open() |> Mogrify.resize_to_fill("400x400") |> Mogrify.save()

      {:ok, file_binary} = File.read(cropped_pic.path)

      {:ok, _request} =
        ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()

      filename
    end
  end

  defp upload_image(_, _), do: nil

  defp slugify_image_name(first_name, last_name) do
    name = first_name <> last_name <> Integer.to_string(Enum.random(0..1000))

    name
    |> Utils.slugified_name()
  end
end
