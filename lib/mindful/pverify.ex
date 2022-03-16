defmodule Mindful.Pverify do
  @moduledoc """
  Mindful.Pverify module
  """

  import Ecto.Query
  alias Mindful.Repo
  alias Mindful.Pverify.UserPverifyData
  alias Mindful.Accounts.User
  alias MindfulWeb.Helpers.Utils

  @providers %{
    "Illinois" => {"Aldad", "1013514447"},
    "New Jersey" => {"Aldad", "1013514447"},
    "New York" => {"Pardeshi", "1174784953"}
  }

  @universal_payers [
    %{code: "00001", name: "Aetna"},
    %{code: "00025", name: "Amerigroup"},
    %{code: "00004", name: "Cigna"},
    %{code: "BO00144", name: "ComPsych Employee Assistance Program"},
    %{code: "000101", name: "Emblem Health"},
    %{code: "01115", name: "GHI"},
    %{code: "00112", name: "Humana"},
    %{code: "00879", name: "Magnacare"},
    %{code: "00007", name: "PTAN (Medicare)"},
    %{code: "01242", name: "Public Employees Health Program - Medicare"},
    %{code: "UHG007", name: "United Healthcare - Optum Behavioral Solutions"}
    # Tricare (Humana Military)
  ]

  # exposed for tests
  def universal_payers(), do: @universal_payers

  def upsert_insurance_details(user, params) do
    payer_code = params["payer_code"] |> String.split(["[", "]"], trim: true) |> List.last()
    payer = user.state.abbr |> payer_codes() |> Enum.find(&(&1.name == payer_code))

    payer_code = if payer, do: payer[:code], else: payer_code
    params = params |> Map.merge(%{"payer_code" => payer_code})

    case Repo.get_by(UserPverifyData, user_id: user.id) do
      nil ->
        prepare_user_pverify_data_changeset(user)

      data ->
        data
    end
    |> UserPverifyData.changeset(params)
    |> Repo.insert_or_update()
  end

  def list_user_pverify_data(verified \\ nil) do
    query = UserPverifyData |> preload(:user) |> join(:inner, [upd], u in assoc(upd, :user))

    query =
      if not is_nil(verified) do
        query |> where([..., u], u.pverify_eligibility_verified == ^verified)
      else
        query
      end

    query
    |> Repo.all()
    |> populate_payer_names()
    |> Enum.group_by(& &1.payer_name)
  end

  def populate_payer_names(data) do
    data
    |> Enum.map(fn item ->
      payer_name =
        payer_codes() |> Enum.find(%{}, fn x -> x.code == item.payer_code end) |> Map.get(:name)

      Map.put(item, :payer_name, payer_name)
    end)
  end

  def get_user_pverify_data_by_id(id), do: UserPverifyData |> preload(:user) |> Repo.get(id)

  def get_user_pverify_data(user),
    do: UserPverifyData |> preload(:user) |> Repo.get_by(user_id: user.id)

  def change_user_pverify_data(%User{} = user, attrs \\ %{}) do
    existing_data = UserPverifyData |> Repo.get_by(user_id: user.id)

    data =
      if existing_data do
        existing_data
      else
        prepare_user_pverify_data_changeset(user)
      end

    UserPverifyData.changeset(data, attrs)
  end

  def prepare_user_pverify_data_changeset(user) do
    user = user |> Repo.preload(:state)
    date = Date.utc_today() |> Utils.format_date_as_mmddyy()
    {provider_name, provider_npi} = get_provider_details_from_state(user)

    %UserPverifyData{
      user_id: user.id,
      is_subscriber_patient: true,
      dos_start_date: date,
      dos_end_date: date,
      provider_name: provider_name,
      provider_npi: provider_npi
    }
  end

  def store_pverify_response_data(user, params) do
    UserPverifyData
    |> Repo.get_by(user_id: user.id)
    |> UserPverifyData.pverify_changeset(params)
    |> Repo.update()
  end

  defp get_provider_details_from_state(user) do
    case Map.get(@providers, user.state.name) do
      nil -> {"", ""}
      data -> data
    end
  end

  def payer_code_names(state_abbr) do
    state_abbr
    |> payer_codes()
    |> Enum.map(fn item ->
      "#{item.name} [#{item.code}]"
    end)
    |> List.insert_at(-1, "Other Payers")
  end

  def payer_codes("il") do
    [
      %{code: "000936", name: "Aetna Better Health (IL)"},
      %{code: "01328", name: "Ambetter"},
      %{code: "00033", name: "BCBS of Illinois"},
      %{code: "01356", name: "Blue Cross Community Health Plans"},
      %{code: "01026", name: "Bright Health"},
      %{code: "01078", name: "CountyCare"},
      %{code: "00114", name: "Illinois Medicaid"},
      %{code: "00902", name: "Meridian Health Plan of Illinois"},
      %{code: "00485", name: "Molina Healthcare of Illinois"},
      %{code: "00418", name: "WellCare Health Plans"}
      # Magellan
    ]
    |> Enum.concat(@universal_payers)
    |> Enum.sort_by(& &1.name)
  end

  def payer_codes("nj") do
    [
      %{code: "000942", name: "Aetna Better Health (NJ)"},
      %{code: "01000", name: "AmeriHealth New Jersey"},
      %{code: "00045", name: "BCBS of New Jersey (Horizon)"},
      %{code: "01069", name: "Clover Health - CarePoint Medicare Advantage"},
      %{code: "00234", name: "Healthfirst of New Jersey"},
      %{code: "00297", name: "Horizon New Jersey Health"},
      %{code: "00161", name: "New Jersey Medicaid"}
    ]
    |> Enum.concat(@universal_payers)
    |> Enum.sort_by(& &1.name)
  end

  def payer_codes("ny") do
    [
      %{code: "00349", name: "Affinity Health Plan"},
      %{code: "00047", name: "BCBS of New York (Empire)"},
      %{code: "00329", name: "Fidelis Care New York"},
      %{code: "00110", name: "Healthfirst New York"},
      %{code: "00634", name: "Local 1199"},
      %{code: "00659", name: "MetroPlus Health Plan"},
      %{code: "00163", name: "New York Medicaid"},
      %{code: "01213", name: "Oscar Health EDI"},
      %{code: "00975", name: "Tricare East"},
      %{code: "00394", name: "Union Pacific Railroad Employee Health Systems"}
    ]
    |> Enum.concat(@universal_payers)
    |> Enum.sort_by(& &1.name)
  end

  def payer_codes(_state), do: payer_codes()

  def payer_codes(), do: @universal_payers
end
