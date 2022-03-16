defmodule Mindful.Factories.Post do
  @moduledoc false

  alias Mindful.Blog.Post

  defmacro __using__(_opts) do
    quote do
      def post_factory do
        %Post{
          pic_path: "https://files.mindful.care/images/mindfulcareweblogo.svg",
          title: "Brooklyn",
          subtitle: "",
          body: "Fort Greene",
          slug: "fort-greene-psychiatry"
        }
      end
    end
  end
end
