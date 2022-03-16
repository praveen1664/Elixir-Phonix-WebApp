defmodule Mindful.Prospects do
  @moduledoc """
  The Prospects context.
  """

  import Ecto.Query
  alias Mindful.Repo
  alias Mindful.Prospects.{Invite, Premarket}

  def create_premarket(attrs \\ %{}) do
    %Premarket{}
    |> Premarket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking premarket changes.
  """
  def change_premarket(%Premarket{} = premarket, attrs \\ %{}) do
    Premarket.changeset(premarket, attrs)
  end

  @doc """
  Gets the last invite that was sent to the given email.
  """
  def get_latest_invite(email) do
    Invite
    |> where([i], i.to == ^email)
    |> order_by([i], desc: i.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def create_invite(attrs) do
    %Invite{}
    |> Invite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes any past invites for the given email and sends a notification to the billing
  admin who created the most recent invite if one exists.
  """
  def delete_invites_and_notify_billing(email, url) do
    {_, invites} = Invite |> where([i], i.to == ^email) |> select([i], i) |> Repo.delete_all()

    if length(invites) > 0 do
      invites
      |> List.first()
      |> Mindful.Accounts.UserNotifier.deliver_card_connected_alert(url)
    end
  end
end
