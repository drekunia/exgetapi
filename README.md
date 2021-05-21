# Exgetapi

<!-- **TODO: Add description** -->

## Requirements

Elixir and PostgreSQL installed

## Installation

Run these commands in terminal:

- `git clone https://github.com/drekunia/exgetapi.git`
- `cd exgetapi`
- `mix deps.get`
- `cp config/config.exs.example config/config.exs`

Set your PostgreSQL database configuration in `config/config.exs`, then run:

- `mix ecto.create && mix ecto.migrate`

You can add you own records to database, or use the seeder:

- `mix run priv/repo/seeds.exs`

Then run:

- `iex -S mix`

The server runs on port `:4000` by default. You can change it in `lib/exgetapi/application.ex` on line `16`.
<br><br>
You can send GET requests using Postman or your web browser.

<!-- If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exgetapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exgetapi, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exgetapi](https://hexdocs.pm/exgetapi). -->
