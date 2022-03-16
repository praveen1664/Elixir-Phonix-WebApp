defmodule MindfulWeb.OnboardingLive.ErrorHandler do
  @moduledoc """
  Mindful.OnboardingLive.ErrorHandler is a module to handle errors being extract from changeset and
  returned to the interface.
  """

  defstruct message: "", messages: [], count: ""

  alias __MODULE__, as: Handler

  @type t :: %__MODULE__{}

  @doc """
  Extract error for a given key into a changeset that contain errors and returns a tuple.

  When changeset contain errors returns a tuple {true, %ErrorHandler{message: "Message"}}
  When changeset does not contain errors returns a tuple {false, %ErrorHandler{}}

  ## Examples:

    iex> MindfulWeb.OnboardingLive.ErrorHandler.extract(:some_key, changeset_with_errors)
    iex> {true, %ErrorHandler{message: "Message", count: ""}}

    iex> MindfulWeb.OnboardingLive.ErrorHandler.extract(:some_key, changeset_with_no_errors)
    iex> {false, %ErrorHandler{message: "", count: ""}}
  """
  @spec extract(atom(), map()) :: {boolean(), t()}
  def extract(key, %{errors: errors}) do
    case Keyword.get(errors, key) do
      {message, opts} ->
        count = Keyword.get(opts, :count, "")
        {true, %Handler{message: message, count: "#{count}"}}

      _ ->
        {false, %Handler{}}
    end
  end
end
