defmodule MindfulWeb.SharedView do
  use MindfulWeb, :view

  def thumbnail_url(image_path) do
    Application.get_env(:mindful, :bucket)[:url_head] <>
      String.replace(image_path, ".", "_thumbnail.")
  end

  def callable_phone(phone), do: String.replace(phone, ~r/\D/, "")

  def offices_to_datalist(offices, conn, state) do
    offices
    |> Enum.map(fn office ->
      path = Routes.office_path(conn, :show, state, office)
      [office.name, office.lat, office.lng, path]
    end)
    |> Jason.encode!()
  end
end
