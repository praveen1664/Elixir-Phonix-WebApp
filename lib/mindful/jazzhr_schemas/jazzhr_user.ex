defmodule Mindful.JazzhrSchemas.JazzhrUser do
  @moduledoc """
  This is the schema for a user from the Jazzhr API.
  """

  use Ecto.Schema

  schema "jazzhr_users" do
    field :uuid, :string
    field :first_name, :string
    field :last_name, :string
  end
end
