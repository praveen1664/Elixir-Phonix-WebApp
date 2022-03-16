defmodule MindfulWeb.GoogleBusinessAdapter do
  @moduledoc """
  Adapter for working with the Google My Business API.
  """

  alias Mindful.Locations

  @doc """
  Go and get all of the location ids and their associated address info
  and save them to the database. Then, map through each location and get
  the reviews for each according, filtering for the most recent 10 that are 4 - 5 stars
  and save them to the database.
  """
  def refresh_reviews(access_token) do
    # uri = "https://mybusinessaccountmanagement.googleapis.com/v1/accounts"

    # {:ok, %{body: resp}} = HTTPoison.get(uri, [{"Authorization", "Bearer #{access_token}"}])

    account_id = Application.get_env(:mindful, :google_mybusiness)[:account_id]

    uri = "https://mybusinessbusinessinformation.googleapis.com/v1/#{account_id}/locations"
    params = "?read_mask=name,storefront_address,title&page_size=100"

    {:ok, %{body: resp}} =
      HTTPoison.get(uri <> params, [{"Authorization", "Bearer #{access_token}"}])

    case Jason.decode(resp) do
      {:ok, %{"locations" => []}} ->
        # no locations, don't do anything
        nil

      {:ok, %{"locations" => locations}} when is_list(locations) ->
        locations
        |> Enum.map(fn loc ->
          address =
            Enum.join(loc["storefrontAddress"]["addressLines"], " ") <>
              ", " <> loc["storefrontAddress"]["locality"]

          %{
            location_id: String.replace(loc["name"], "locations/", ""),
            title: loc["title"],
            address: address
          }
        end)
        |> Locations.delete_and_save_all_google_locations()
        |> fetch_reviews_for_locations(account_id, access_token)

      {:ok, err} ->
        err
    end
  end

  defp fetch_reviews_for_locations(locations, account_id, access_token) do
    Enum.reduce(locations, [], fn %{location_id: location_id}, acc ->
      # get reviews for this location
      uri = "https://mybusiness.googleapis.com/v4/#{account_id}/locations/#{location_id}/reviews"

      params = "?page_size=100"

      {:ok, %{body: resp}} =
        HTTPoison.get(uri <> params, [{"Authorization", "Bearer #{access_token}"}])

      case Jason.decode(resp) do
        {:ok, %{"reviews" => []}} ->
          acc

        {:ok, %{"reviews" => reviews}} when is_list(reviews) ->
          good_reviews =
            reviews
            |> Enum.reject(&is_nil(&1["comment"]))
            |> Enum.reject(&(&1["starRating"] != "FOUR" && &1["starRating"] != "FIVE"))
            |> Enum.map(fn review ->
              %{
                location_id: location_id,
                name: review["reviewer"]["displayName"] || "Recent patient",
                rating: if(review["starRating"] == "FOUR", do: 4, else: 5),
                comment: review["comment"],
                created_at:
                  DateTime.truncate(Timex.parse!(review["createTime"], "{RFC3339}"), :second)
              }
            end)

          good_reviews ++ acc

        {:ok, _err} ->
          acc
      end
    end)
    |> Locations.delete_and_save_all_google_reviews()
  end
end
