<div align="center">
  <h1> ExMon API </h1>
  <h2>
    This project is part of the Udemy course: Elixir e Phoenix do zero! Crie sua primeira API Phoenix.
  </h2>
</div>

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
# Creating the project from scratch

### Generating the project
```bash
  $ mix phx.new ex_mon --no-webpack --no-html
```
### Generating the database
```bash
  $ mix ecto.create
```
### Creating the trainer migration
```bash
  $ mix ecto.gen.migration create_trainer_table
```
```elixir
# priv/repo/migrations/20210406091522_create_trainer_table.exs
defmodule ExMon.Repo.Migrations.CreateTrainerTable do
  use Ecto.Migration

  # Within this def change
    # The ecto will be responsible for the creation or downgrading, if necessary
  def change do
    # Primary key: false
      # Do not generate the primary key itself as integer,
      # we will create the format of the primary key ourselves
    create table(:trainers, primary_key: false) do
      add :id, :uuid, primary_key: true # Here we are creating the primary key as uuid
      add :name, :string
      # password_hash will be an encrypted password
      add :password_hash, :string
      timestamps()
    end
  end
end
```
```bash
  $ mix ecto.migrate
```
