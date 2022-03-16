defmodule Mindful.Factories.State do
  @moduledoc false

  alias Mindful.Locations.State

  defmacro __using__(_opts) do
    quote do
      def state_factory do
        %State{
          abbr: "ny",
          name: "New York",
          description: "The New York State",
          image_path: Faker.Avatar.image_url(200, 200),
          slug: "new-york",
          coming_soon: false,
          available_treatments: ["medical_management", "therapy", "substance_use_counseling"]
        }
      end
    end
  end
end
