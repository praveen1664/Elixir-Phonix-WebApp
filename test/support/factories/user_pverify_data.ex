defmodule Mindful.Factories.UserPverifyData do
  @moduledoc false

  alias Mindful.Pverify.UserPverifyData
  alias MindfulWeb.Helpers.Utils

  defmacro __using__(_opts) do
    quote do
      def user_pverify_data_factory do
        %UserPverifyData{
          payer_code: Faker.String.base64(10),
          provider_name: Faker.String.base64(10),
          provider_npi: Faker.String.base64(10),
          subscriber_member_id: Faker.String.base64(10),
          dos_start_date: Date.utc_today() |> Utils.format_date_as_mmddyy(),
          dos_end_date: Date.utc_today() |> Utils.format_date_as_mmddyy(),
          eligibility_details: []
        }
      end
    end
  end
end
