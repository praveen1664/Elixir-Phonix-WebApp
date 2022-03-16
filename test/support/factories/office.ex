defmodule Mindful.Factories.Office do
  @moduledoc false

  alias Mindful.Locations.Office

  defmacro __using__(_opts) do
    quote do
      def office_factory do
        %Office{
          state: build(:state),
          city: "Brooklyn",
          description: "",
          name: "Fort Greene",
          slug: "fort-greene-psychiatry",
          street: "41 Flatbush Ave",
          suite: "2nd Floor",
          zip: "11217",
          lat: 123.456,
          lng: 124.456,
          google_location_id: "caCI2jcuOmthCVBQ",
          phone: "(516) 407-8558",
          fax: "(949) 419-3482",
          hours: "Sunday - Friday: 8am - 6pm",
          email: "hello@mindful.care"
        }
      end
    end
  end
end
