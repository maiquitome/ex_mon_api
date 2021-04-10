<div align="center">
  <h1> ExMon API </h1>
  <h2>
    This project is part of the Udemy course: Elixir e Phoenix do zero! Crie sua primeira API Phoenix.
  </h2>
</div>

### What have we learned?
  * Creating a REST JSON API
  * Interacting with the database using Ecto
  * Good practices in code separation by context
  * Interaction with external APIs via HTTP protocol

  * Trainer
    - Create, delete, update, read trainer
  * Pokemon Team
    - Create team, delete team, update team
  * Read Pokemon information

### To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

<div align="center">
  <h1> Creating the project from scratch </h1>
</div>

### 📚 Recommended study topics for this project
* Map
  - https://elixirschool.com/en/lessons/basics/collections/#maps
* Struct
  - https://elixirschool.com/en/lessons/basics/modules/#structs
* Ecto
  1. Basics
      - https://elixirschool.com/en/lessons/ecto/basics/
  2. Changesets
      - https://elixirschool.com/en/lessons/ecto/changesets/

### Generating the project
```bash
  $ mix phx.new ex_mon --no-webpack --no-html
```
### Generating the database
```bash
  $ mix ecto.create
```
### Creating the trainer migration
* Migrations — a mechanism to create, modify, and destroy database tables and indexes
  - https://elixirschool.com/en/lessons/ecto/basics/
* Migrations are used to modify your database schema over time.
  - https://hexdocs.pm/ecto_sql/Ecto.Migration.html
* Command to generate our migration
  ```bash
    $ mix ecto.gen.migration create_trainer_table
  ```
* in the file created: __priv/repo/migrations/20210406091522_create_trainer_table.exs__
  ```elixir
  defmodule ExMon.Repo.Migrations.CreateTrainerTable do
    use Ecto.Migration

    # Within this def change
      # The ecto will be responsible for the creation or downgrading, if necessary
    def change do
      # primary key: false
        # Do not generate the primary key itself as integer,
        # we will create the format of the primary key ourselves
      create table(:trainers, primary_key: false) do
        # :trainers is the table name
        # UUID - universally unique identifier
        add :id,            :uuid,  primary_key: true # Here we are creating the primary key as uuid
        add :name,          :string
        add :password_hash, :string # password_hash will be an encrypted password
        timestamps()
        # timestamps() is a function that automatically inserts the inserted_at and updated_at columns
      end
    end
  end
  ```
* create in the database
  ```bash
    $ mix ecto.migrate
  ```
### Creating the trainer schema
* Now let's build the logic to insert the trainer in the database.
  - Every time we need to do a database operation (insert, update...) we need to deal with schemas.
  - Making an analogy, schemas are similar to models in other web frameworks.
  - But it's not a model, because usually model has attributes and behaviours.
  - The schema only has a representation of the data and validations of that data.
* Create the file __lib/ex_mon/trainer.ex__
```elixir
defmodule ExMon.Trainer do
  use Ecto.Schema
  import Ecto.Changeset

  # If it was an incremental integer id we wouldn't need to do that but...
  # as it is UUID we need to make it clear
  # @primary_key - configures the schema primary key. It expects a tuple {field_name, type, options}
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  # mirror scheme of our migration
  # the fields are the same as in our migration
  schema "trainers" do
    field :name,          :string
    field :password_hash, :string
    timestamps()
  end

  # to insert anything into the database, we need to create changesets
  # changesets are structures with powers
  @required_params [:name, :password_hash]
  # params are the parameters that I want to create my schema
  # for example: what is the name? what is the password?
  def changeset(params) do
    %__MODULE__{}
    # Cast - Applies the given params as changes for the given data
    # according to the given set of permitted keys.
    # cast(data, params, permitted, opts \\ [])
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
### Encrypting the trainer password
* in the __lib/ex_mon/trainer.ex__
  - in the code below:
    ```elixir
    schema "trainers" do
      field :name, :string
      field :password_hash, :string
      # here
      timestamps()
    end
    ```
  - add this code:
    ```elixir
    field :password, :string, virtual: true
    ```
    - virtual: true
      - means that this field doesn't exist in the database, only in the schema
* in the __mix.exs__
  - in the code below:
    ```elixir
    defp deps do
      [
        {:phoenix, "~> 1.5.8"},
        {:phoenix_ecto, "~> 4.1"},
        {:ecto_sql, "~> 3.4"},
        {:postgrex, ">= 0.0.0"},
        {:phoenix_live_dashboard, "~> 0.4"},
        {:telemetry_metrics, "~> 0.4"},
        {:telemetry_poller, "~> 0.4"},
        {:gettext, "~> 0.11"},
        {:jason, "~> 1.0"},
        {:plug_cowboy, "~> 2.0"},
        # add here
      ]
    end
    ```
  - add this code:
    ```elixir
    {:argon2_elixir, "~> 2.0"}
    ```
  - and run this command to download this new dependency:
    ```bash
    $ mix deps.get
    ```
* in the __lib/ex_mon/trainer.ex__
  - in the code below:
    ```elixir
    def changeset(params) do
      %__MODULE__{}
      |> cast(params, @required_params)
      |> validate_required(@required_params)
      |> validate_length(:password_hash, min: 6)
      # add here
    end
    ```
    - add this code:
      ```elixir
      |> put_pass_hash()
      ```
  - create the functions:
    ```elixir
    defp put_pass_hash(
      %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
    ) do
      # change(data, changes \\ %{})
      change(changeset, Argon2.add_hash(password))
    end

    # no match
    defp put_pass_hash(changeset), do: changeset
    ```
    - https://hexdocs.pm/ecto/Ecto.Changeset.html#change/2
* explanation:
  - using password_hash
    ```bash
    iex> params = %{name: "Maiqui", password_hash: "123456"}
    %{name: "Maiqui", password_hash: "123456"}
    ```
  - changeset without being encrypted
    ```bash
    iex> changeset = ExMon.Trainer.changeset(params)
    #Ecto.Changeset<
      action: nil,
      changes: %{name: "Maiqui", password_hash: "123456"},
      errors: [],
      data: #ExMon.Trainer<>,
      valid?: true
    >
    ```
  - encrypting
    ```bash
    iex> Argon2.add_hash("123456")
    %{
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$uQdW8RwlZWJvwFYNE73yoA$1yNyDBlMmfTUOd9z/z2A9g1PxMtnt3zzoGThZsi3Ops"
    }
    ```
* now let's use __password__ instead of __password_hash__
  - in the code below:
      ```elixir
      @required_params [:name, :password_hash]

      def changeset(params) do
        %__MODULE__{}
        |> cast(params, @required_params)
        |> validate_required(@required_params)
        |> validate_length(:password_hash, min: 6)
        |> put_pass_hash()
      end
      ```
    - change __password_hash__ to __password__:
      ```elixir
      @required_params [:name, :password]

      def changeset(params) do
        %__MODULE__{}
        |> cast(params, @required_params)
        |> validate_required(@required_params)
        |> validate_length(:password, min: 6)
        |> put_pass_hash()
      end
      ```
    - recompile
      ```bash
      iex> recompile
      Compiling 1 file (.ex)
      :ok
      ```
  - using __password__
    ```bash
    iex> params = %{name: "Maiqui", password: "123456"}
    %{name: "Maiqui", password: "123456"}
    ```
  - changeset encrypted
    ```bash
    iex> changeset = ExMon.Trainer.changeset(params)
    #Ecto.Changeset<
      action: nil,
      changes: %{
        name: "Maiqui",
        password: "123456",
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$DxQLzWqhlsAQY+hKj7WuPg$JPtnPnKmCwHseV1wA9pNGUAvjcrP+AQJNGvI9R/jYtQ"
      },
      errors: [],
      data: #ExMon.Trainer<>,
      valid?: true
    >
    ```
      - the password field will not be added to the database because this field is only virtual
      - https://hexdocs.pm/ecto/Ecto.Schema.html
### Making the trainer's build
* In the __lib/ex_mon/trainer.ex__
  - add this code
    ```elixir
    def build(params) do
      params
      |> changeset()
      # Applies the changeset action only if the changes are valid.
      |> apply_action(:insert)
      # apply_action(changeset, action)
      # The action may be any atom.
    end
    ```
  - create the params
    ```bash
    iex> params = %{name: "Maiqui", password: "123456"}
    %{name: "Maiqui", password: "123456"}
    ```
  - returns a tuple with _ok_ and a _valid struct_
    ```bash
    iex> ExMon.Trainer.build(params)
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:built, "trainers">,
      id: nil,
      inserted_at: nil,
      name: "Maiqui",
      password: "123456",
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$GhBPky81NBhKhq9X6BDSNw$v5jQumWr1lg8Uc1p2+RUdathZluhH/vFApYWeXdHq/M",
      updated_at: nil
    }}
    ```
    - if I do a _Pattern Matching_
      ```bash
      iex> {:ok, struct} = ExMon.Trainer.build(params)
      {:ok,
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:built, "trainers">,
        id: nil,
        inserted_at: nil,
        name: "Maiqui",
        password: "123456",
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$4q7KAll0E9BV4RLWGX60zw$y2x2Ob0YZjQGjT4SXLmu6w9boptiyLXNKfIGgzDryWM",
        updated_at: nil
      }}
      ```
    - I will have the _changeset_ inside the _struct_
      ```bash
      iex> struct
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:built, "trainers">,
        id: nil,
        inserted_at: nil,
        name: "Maiqui",
        password: "123456",
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$4q7KAll0E9BV4RLWGX60zw$y2x2Ob0YZjQGjT4SXLmu6w9boptiyLXNKfIGgzDryWM",
        updated_at: nil
      }
      ```

* learn more about: __apply_action(changeset, action)__
  - https://hexdocs.pm/ecto/Ecto.Changeset.html#apply_action/2

### The Create Trainer module
* create __lib/ex_mon/trainer/create.ex__
  - Add this code
  ```elixir
    defmodule ExMon.Trainer.Create do
      # alias ExMon.{Repo, Trainer}

      def call(params) do
        params
        |> ExMon.Trainer.build()
        |> create_trainer()
      end

      # inserting into the database
      defp create_trainer({:ok, struct}), do: ExMon.Repo.insert(struct)
      defp create_trainer({:error, _changeset} = error), do: error
    end
  ```
* making the interface simpler
  - in the __lib/ex_mon.ex__ add this code
  ```elixir
  defmodule ExMon do
    # alias ExMon.Trainer

    defdelegate create_trainer(params),
      to: ExMon.Trainer.Create,
      as: :call
  end
  ```
  - to learn more about facades
    - https://dev.to/justgage/saner-apps-with-the-facade-pattern-4e29
    - http://www.petecorey.com/blog/2018/09/03/using-facades-to-simplify-elixir-modules/
* testing the code
  - create the params
    ```bash
    iex> params = %{name: "Maiqui", password: "123456"}
    %{name: "Maiqui", password: "123456"}
    ```
  - inserting a trainer in the database
    ```bash
    iex> ExMon.create_trainer(params)
    [debug] QUERY OK db=14.5ms queue=97.8ms idle=719.2ms
    INSERT INTO "trainers" ("name","password_hash","id","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5) ["Maiqui", "$argon2id$v=19$m=131072,t=8,p=4$SgXPR4GA6nZkbCseL9NRVA$R4tWwraUkZL4O297MuYs4Du1nBch4t8+DzelAqhCips", <<4, 89, 172, 25, 78, 35, 77, 105, 169, 254, 92, 57, 39, 57, 178, 17>>, ~N[2021-04-10 10:21:54], ~N[2021-04-10 10:21:54]]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "0459ac19-4e23-4d69-a9fe-5c392739b211",
      inserted_at: ~N[2021-04-10 10:21:54],
      name: "Maiqui",
      password: "123456",
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$SgXPR4GA6nZkbCseL9NRVA$R4tWwraUkZL4O297MuYs4Du1nBch4t8+DzelAqhCips",
      updated_at: ~N[2021-04-10 10:21:54]
    }}
    ```
### Creating the create trainer route
* in the __lib/ex_mon_web/router.ex__
  - in this code
    ```elixir
    # http://localhost:4000/api/name_of_the_route
    scope "/api", ExMonWeb do
      pipe_through :api
      # add here
    end
    ```
  - add
    ```elixir
    resources "/trainers", TrainersController, only: [:create, :show, :delete, :update]
    ```
* create __lib/ex_mon_web/controllers/trainers_controller.ex__
  - add this code
    ```elixir
    defmodule ExMonWeb.TrainersController do
      use ExMonWeb, :controller

      # create() The first parameter is always conn, a struct which holds information about the request such as the host, path elements, port, query string, and much more.
      # https://hexdocs.pm/phoenix/controllers.html

      def create(conn, params) do
        params
        |> ExMon.create_trainer()
        # every Phoenix action must return a connection:
        |> handle_response(conn)
      end

      defp handle_response({:ok, trainer}, conn) do
        conn
        |> put_status(:ok)
        |> render("create.json", trainer: trainer)
      end
    end
    ```
* command to see all routes
  ```bash
  $ mix phx.routes
  Compiling 1 file (.ex)
        trainers_path  GET     /api/trainers/:id       ExMonWeb.TrainersController :show
        trainers_path  POST    /api/trainers           ExMonWeb.TrainersController :create
        trainers_path  PATCH   /api/trainers/:id       ExMonWeb.TrainersController :update
                       PUT     /api/trainers/:id       ExMonWeb.TrainersController :update
        trainers_path  DELETE  /api/trainers/:id       ExMonWeb.TrainersController :delete
  live_dashboard_path  GET     /dashboard              Phoenix.LiveView.Plug :home
  live_dashboard_path  GET     /dashboard/:page        Phoenix.LiveView.Plug :page
  live_dashboard_path  GET     /dashboard/:node/:page  Phoenix.LiveView.Plug :page
            websocket  WS      /live/websocket         Phoenix.LiveView.Socket
            longpoll   GET     /live/longpoll          Phoenix.LiveView.Socket
            longpoll   POST    /live/longpoll          Phoenix.LiveView.Socket
            websocket  WS      /socket/websocket       ExMonWeb.UserSocket
  ```
* to learn more about
  - https://hexdocs.pm/phoenix/controllers.html
  - https://hexdocs.pm/plug/Plug.Conn.Status.html
