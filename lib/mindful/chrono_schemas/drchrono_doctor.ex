defmodule Mindful.ChronoSchemas.DrchronoDoctor do
  @moduledoc """
  This is the schema for a doctor from the Drchrono API.
  """

  use Ecto.Schema

  schema "drchrono_doctors" do
    field :uuid, :integer
    field :first_name, :string
    field :last_name, :string
    field :job_title, :string
    field :specialty, :string
    field :office_phone, :string
    field :profile_picture, :string
    field :suffix, :string
    field :timezone, :string
  end
end
