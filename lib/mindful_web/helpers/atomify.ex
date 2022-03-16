defmodule MindfulWeb.Helpers.Atomify do
  @moduledoc """
  Atomify module with helper functions.
  """

  @doc """
  Atomify Atomify keys.

  ## Examples

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms("1")
      "1"

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms(92321)
      92321

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms(%{atom: "value"})
      %{atom: "value"}

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms(%{atom: "value", Atomify: %{atom: "value"}})
      %{atom: "value", Atomify: %{atom: "value"}}

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms(%{"string" => "value", Atomify: %{atom: "value"}})
      %{string: "value", Atomify: %{atom: "value"}}

      iex> MindfulWeb.Helpers.Atomify.keys_to_atoms(%{"string" => "value", "Atomify" => %{"string" => "value"}})
      %{string: "value", Atomify: %{string: "value"}}
  """
  def keys_to_atoms(%DateTime{} = value), do: value
  def keys_to_atoms(%Plug.Upload{} = value), do: value
  def keys_to_atoms(%NaiveDateTime{} = value), do: value
  def keys_to_atoms(%Date{} = value), do: value
  def keys_to_atoms(%Time{} = value), do: value

  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{} do
      if is_binary(key) do
        {String.to_existing_atom(key), keys_to_atoms(val)}
      else
        {key, keys_to_atoms(val)}
      end
    end
  end

  def keys_to_atoms(value), do: value
end
