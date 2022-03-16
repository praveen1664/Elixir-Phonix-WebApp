# Mindful

## First Time Setup

It is recommended to use a version manager like https://github.com/asdf-vm/asdf to handle Elixir and Erlang versions.

After installing asdf, simply add the required plugins and install the versions used for this project:
```
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir

asdf install elixir 1.12
asdf install erlang 24.2
```

You can then run the following to set the correct versions:
```
asdf global elixir 1.12
asdf global erlang 24.2
```

### Possible Issues with Install

- **Erlang Installation Failed but Reinstallation Fails due to Existing Build**

Solution: Use TextEdit to remove the lines related to the failed version in `.asdf/plugins/erlang/kerl-home/otp_builds` and `.asdf/plugins/erlang/kerl-home/otp_installations`

https://github.com/asdf-vm/asdf/issues/562#issuecomment-628613034
https://github.com/asdf-vm/asdf-erlang/issues/143#issuecomment-628453296

- **Erlang OTP 24 Compilation error**

Solution: Install `openssl` and `wxmac` using `homebrew` in a **non-Rosetta Terminal**

https://github.com/asdf-vm/asdf-erlang/issues/207#issuecomment-883216342

### Starting the local server

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install frontend dependencies with `cd assets && npm install`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

**Sanity check:** Make sure `iex -S mix`, `mix compile` and `mix test` can run without any issues

### Running tests

- mix test or mix test path_to_file.exs

### Running coverage by excoveralls

- mix coveralls (the vanilla output on console)
- mix coveralls.detail - [More info](https://github.com/parroty/excoveralls#mix-coverallsdetail-show-coverage-with-detail)
- mix coveralls.html - [More info](https://github.com/parroty/excoveralls#mix-coverallshtml-show-coverage-as-html-report)

---

⚠️ To run all the features properly you may need to setup up locally the env varibles, if needed ask someone help to get those

Once you got the env variables follow the steps:

- Create an `.env` file on the root of the project
- Paste the content you copy with a coworker
- Run `source .env`
- Restart the app

## Seeding your local database

There are a handful of static drchrono schema records in `priv/repo/seeds.exs` that can be used to populate your local database. To seed your database run `mix run priv/repo/seeds.exs`.

## Deployment

TODO



