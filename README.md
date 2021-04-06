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

<div align="center">
  <h1> Creating the project from scratch </h1>
</div>

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
### Creating the trainer schema
```elixir
# lib/ex_mon/trainer.ex
defmodule ExMon.Trainer do
  use Ecto.Schema
  import Ecto.Changeset

  # If it was an incremental integer id we wouldn't need to do that but...
  # as it is UUID we need to make it clear
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "trainers" do
    field :name, :string
    field :password_hash, :string
    timestamps()
  end

  @required_params [:name, :password_hash]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
```
✔️ All fields filled in (OK)
```bash
iex> params = %{name: "Maiqui", password_hash: "123456senha"}
%{name: "Maiqui", password_hash: "123456senha"}
```
```bash
iex> ExMon.Trainer.changeset(params)
#Ecto.Changeset<
  action: nil,
  changes: %{name: "Maiqui", password_hash: "123456senha"},
  errors: [],
  data: #ExMon.Trainer<>,
  valid?: true
>
```
❌ Empty password field (ERROR)
```bash
iex> params = %{name: "Maiqui"}
%{name: "Maiqui"}
```
```bash
iex> ExMon.Trainer.changeset(params)
#Ecto.Changeset<
  action: nil,
  changes: %{name: "Maiqui"},
  errors: [password_hash: {"can't be blank", [validation: :required]}],
  data: #ExMon.Trainer<>,
  valid?: false
>
```
### Understanding what changesets are
* Changesets allow filtering, casting, validation and definition of constraints when manipulating structs.
  - https://hexdocs.pm/ecto/Ecto.Changeset.html
* In the __lib/ex_mon/trainer.ex__
  - In the code below:
    ```elixir
    def changeset(params) do
      %__MODULE__{}
      |> cast(params, @required_params)
      |> validate_required(@required_params)
      # here
    end
    ```
  - add this code:
    ```elixir
    |> validate_length(:password_hash, min: 6)
    ```
❌ Now if we try to use a password shorter than 6 characters it will result in an error
```bash
iex> recompile
Compiling 1 file (.ex)
:ok
```
```bash
iex> params = %{name: "Maiqui", password_hash: "12345"}
%{name: "Maiqui", password_hash: "12345"}
```
```bash
iex> ExMon.Trainer.changeset(params)
#Ecto.Changeset<
  action: nil,
  changes: %{name: "Maiqui", password_hash: "12345"},
  errors: [
    password_hash: {"should be at least %{count} character(s)",
     [count: 6, validation: :length, kind: :min, type: :string]}
  ],
  data: #ExMon.Trainer<>,
  valid?: false
>
```
