defmodule Mindful do
  @moduledoc """
  Mindful keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.

  This can be used in your application as:

      use Mindful, :schema

  The definitions below will be executed for every schema so keep them short
  and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below.
  Instead, define any helper function in modules and import those modules here.
  """

  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      alias Mindful.Repo

      @timestamps_opts [type: :utc_datetime_usec]
      @type t :: %__MODULE__{}
    end
  end

  def context do
    quote do
      import Ecto.Query

      alias Ecto.Changeset
      alias Mindful.Repo
    end
  end

  @doc """
  When used, dispatch to the appropriate schema
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
