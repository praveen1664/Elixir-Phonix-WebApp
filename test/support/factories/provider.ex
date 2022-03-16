defmodule Mindful.Factories.Provider do
  @moduledoc false

  alias Mindful.Clinicians.Provider

  defmacro __using__(_opts) do
    quote do
      def provider_factory do
        first_name = Faker.Person.first_name()
        last_name = Faker.Person.last_name()

        about =
          1..4
          |> Faker.Lorem.sentences()
          |> List.to_string()

        %Provider{
          first_name: first_name,
          last_name: last_name,
          credential_initials: Faker.Util.pick(["MD", "NP", "PsyD"]),
          job_title: "Medical Doctor",
          image_path: Faker.Avatar.image_url(200, 200),
          about: about,
          details: about,
          slug: Faker.Internet.slug([first_name, last_name]),
          rank: Faker.Util.pick([1, 2, 3, 4, 5])
        }
      end
    end
  end
end
