defmodule MindfulWeb.ViewHelpers do
  @moduledoc """
  Conveniences for common functions used across views.
  """

  def is_admin?(%Mindful.Accounts.User{superadmin: true}), do: true
  def is_admin?(%Mindful.Accounts.User{roles: roles}) when is_list(roles), do: roles != []
  def is_admin?(_), do: false

  def formalize_name(provider) do
    provider.first_name <> " " <> provider.last_name <> ", " <> provider.credential_initials
  end

  def uploaded_img_url(image_path) do
    Application.get_env(:mindful, :bucket)[:url_head] <> image_path
  end

  def uploaded_thumb_url(image_path) do
    Application.get_env(:mindful, :bucket)[:url_head] <>
      String.replace(image_path, ".", "_thumbnail.")
  end

  def blob_to_html(txt) do
    txt
    |> Earmark.as_html!(%Earmark.Options{smartypants: false})
    |> Phoenix.HTML.raw()
  end

  def cents_to_dollars(cents) when is_integer(cents) do
    {dollars, pennies} = cents |> to_string() |> String.split_at(-2)
    "$" <> dollars <> "." <> pennies
  end

  @spec truncate(String.t(), integer()) :: String.t()
  def truncate(string, length \\ 50) do
    string
    |> String.slice(0, length)
    |> String.trim_trailing()
    |> Kernel.<>("...")
  end
end
