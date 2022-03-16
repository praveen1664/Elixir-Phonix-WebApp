defmodule Mindful.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Mindful.Repo

  # State
  use Mindful.Factories.State
  # Office
  use Mindful.Factories.Office
  # User
  use Mindful.Factories.User
  # Provider
  use Mindful.Factories.Provider
  # Appointment
  use Mindful.Factories.Appointment
  # UserPverifyData
  use Mindful.Factories.UserPverifyData
  # Post
  use Mindful.Factories.Post
end
