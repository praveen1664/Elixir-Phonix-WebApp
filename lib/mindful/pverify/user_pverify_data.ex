defmodule Mindful.Pverify.UserPverifyData do
  @moduledoc """
  Mindful.Pverify.UserPverifyData module
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_pverify_data" do
    field :payer_code, :string
    field :provider_name, :string
    field :provider_npi, :string
    field :subscriber_member_id, :string
    field :is_subscriber_patient, :boolean, default: true
    field :dos_start_date, :string
    field :dos_end_date, :string
    field :insurance_card_front, :string
    field :insurance_card_back, :string

    field :eligibility_details, {:array, :map}, default: []
    field :individual_deductible_in_net, :string
    field :individual_deductible_remaining_in_net, :string
    field :individual_oop_remaining_in_net, :string
    field :co_insurance_in_net, :string
    field :co_pay_in_net, :string
    field :is_hmo_plan, :boolean
    field :plan_coverage_summary, :map
    field :other_payer_info, :map

    belongs_to :user, Mindful.Accounts.User

    timestamps()
  end

  @required_attrs ~w(payer_code provider_name provider_npi subscriber_member_id)a
  @optional_attrs ~w(user_id is_subscriber_patient dos_start_date dos_end_date insurance_card_front insurance_card_back)a
  @pverify_attrs ~w(eligibility_details individual_deductible_in_net individual_deductible_remaining_in_net individual_oop_remaining_in_net
  is_hmo_plan plan_coverage_summary other_payer_info co_insurance_in_net co_pay_in_net)a

  def changeset(data, attrs) do
    data
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
  end

  def pverify_changeset(data, attrs), do: data |> cast(attrs, @pverify_attrs)
end
