defmodule Mindful.Test.Support.Helpers do
  @moduledoc """
  This module defines general testing helpers.
  """

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
