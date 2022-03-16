defmodule Mindful.Factories.User do
  @moduledoc false

  alias Mindful.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        password = Faker.String.base64(20)

        %User{
          email: Faker.Internet.email(),
          password: password,
          hashed_password: Bcrypt.hash_pwd_salt(password),
          drchrono_id: :rand.uniform(100_000_000)
        }
      end
    end
  end
end
