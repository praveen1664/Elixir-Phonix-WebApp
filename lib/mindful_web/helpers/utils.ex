defmodule MindfulWeb.Helpers.Utils do
  @moduledoc """
  This module contain helper functions.
  """

  @type states_list() :: [tuple()]

  @states %{
    "AL" => "Alabama",
    "AK" => "Alaska",
    "AS" => "American Samoa",
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "DC" => "District of Columbia",
    "FL" => "Florida",
    "GA" => "Georgia",
    "GU" => "Guam",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "MP" => "Northern Mariana Is",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "PR" => "Puerto Rico",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "VI" => "Virgin Islands",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming"
  }

  @spec slugified_name(binary()) :: String.t()
  def slugified_name(name) do
    name
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[^A-Za-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  @spec convert_to_keyword_list(map()) :: states_list()
  def convert_to_keyword_list(map) do
    Enum.map(map, fn {key, value} ->
      {key, value}
    end)
  end

  @spec state_abbrs :: [String.t()]
  def state_abbrs(), do: Map.keys(@states) |> Enum.sort()

  @spec name_for_abbr(String.t()) :: String.t() | nil
  def name_for_abbr(abbr) do
    Map.fetch!(@states, abbr)
  rescue
    KeyError -> nil
  end

  @spec supported_image_formats :: [String.t()]
  def supported_image_formats(), do: ["image/jpeg", "image/png"]

  def create_thumbnail(upload, name, file_extension, bucket, folder, opts, size \\ "370x415") do
    filename = "/images/#{folder}/#{name}_thumbnail#{file_extension}"

    cropped_pic =
      upload.path
      |> Mogrify.open()
      |> Mogrify.gravity("Center")
      |> Mogrify.resize_to_fill(size)
      |> Mogrify.save()

    {:ok, file_binary} = File.read(cropped_pic.path)
    ExAws.S3.put_object(bucket, filename, file_binary, opts) |> ExAws.request()
  end

  def format_date_as_mmddyy(nil), do: nil

  def format_date_as_mmddyy(date) when is_bitstring(date) do
    [year, mth, day] = date |> String.split("-")
    mth <> "-" <> day <> "-" <> year
  end

  def format_date_as_mmddyy(date) do
    [year, mth, day] = date |> Date.to_string() |> String.split("-")
    mth <> "-" <> day <> "-" <> year
  end
end
