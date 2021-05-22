# Exgetapi

<!-- **TODO: Add description** -->

An HTTP GET API that filters dummy name and ID data based on value of request parameter `id`

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

The server runs on port `4000` by default. You can change it in `config/config.exs`.

## How to use

Send GET requests with parameter `id` with value of a number or numbers separated by commas (e.g. `/?id=7` or `/?id=1,13,5`).
<br>
Other parameters will be ignored.
<br>
GET request with no `id` will return all data.
<br><br>
Run tests by running `mix test` in terminal.

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
