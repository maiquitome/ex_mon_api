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
        |> put_status(:created)
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
### Rendering Trainer (creating the trainer view)
* create __lib/ex_mon_web/views/trainers_view.ex__
  - add this code:
    ```elixir
    defmodule ExMonWeb.TrainersView do
      use ExMonWeb, :view

      alias ExMon.Trainer

      def render(
        "create.json",
        %{trainer: %Trainer{id: id, name: name, inserted_at: inserted_at}}
      ) do
        %{
          message: "Trainer created!",
          trainer: %{
            id: id,
            name: name,
            inserted_at: inserted_at
          }
        }
      end
    end
    ```
* creating the trainer...
  - start the server
    ```bash
    $ mix phx.server
    ```
  - http post...
    - to run this command you need to have installed: https://httpie.io/docs#installation
      ```bash
      $ http post http://localhost:4000/api/trainers name="Ash Ketchum" password="123456"
      HTTP/1.1 201 Created
      cache-control: max-age=0, private, must-revalidate
      content-length: 143
      content-type: application/json; charset=utf-8
      date: Sat, 10 Apr 2021 17:43:52 GMT
      server: Cowboy
      x-request-id: FnSQH7JhUqDl1QQAAAJh

      {
          "message": "Trainer created!",
          "trainer": {
              "id": "6fc6c812-7950-4461-8145-8f7259281a71",
              "inserted_at": "2021-04-10T17:43:52",
              "name": "Ash Ketchum"
          }
      }
      ```
  - search all the trainers entered in the database
  ```bash
  iex> ExMon.Repo.all(ExMon.Trainer)
  [debug] QUERY OK source="trainers" db=7.7ms decode=1.3ms queue=0.9ms idle=1179.8ms
  SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 []
  [
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "0459ac19-4e23-4d69-a9fe-5c392739b211",
      inserted_at: ~N[2021-04-10 10:21:54],
      name: "Maiqui",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$SgXPR4GA6nZkbCseL9NRVA$R4tWwraUkZL4O297MuYs4Du1nBch4t8+DzelAqhCips",
      updated_at: ~N[2021-04-10 10:21:54]
    },
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "cee4f5a7-1795-4aca-8382-9a95a1657072",
      inserted_at: ~N[2021-04-10 17:13:29],
      name: "Maiqui",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$rQ2YWdFrxoaaYFCdlGVQww$R0mGF1zy+2RfsFY61DInqRXmp6m3yX/gIOngPf+uHeA",
      updated_at: ~N[2021-04-10 17:13:29]
    },
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "6fc6c812-7950-4461-8145-8f7259281a71",
      inserted_at: ~N[2021-04-10 17:43:52],
      name: "Ash Ketchum",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
      updated_at: ~N[2021-04-10 17:43:52]
    }
  ]
  ```
  - catching only __Ash__ using __id__
  ```bash
  iex> ExMon.Repo.get(ExMon.Trainer, "6fc6c812-7950-4461-8145-8f7259281a71")
  [debug] QUERY OK source="trainers" db=1.9ms queue=3.7ms idle=1872.2ms
  SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
  %ExMon.Trainer{
    __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
    id: "6fc6c812-7950-4461-8145-8f7259281a71",
    inserted_at: ~N[2021-04-10 17:43:52],
    name: "Ash Ketchum",
    password: nil,
    password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
    updated_at: ~N[2021-04-10 17:43:52]
  }
  ```
### Handling errors using the Fallback Controller
* It is a common pattern in Phoenix not to treat the error in the main controller;
* It is good practice to create a Fallback Controller;
* Every error that is generated within a controller action is pushed forward and centralises the way we handle errors all in the Fallback Controller;
* All controllers will use the Fallback Controller to handle errors.
* In the __lib/ex_mon_web/controllers/trainers_controller.ex__
  - add the code
    ```elixir
    defmodule ExMonWeb.TrainersController do
      use ExMonWeb, :controller

      # every controller that uses fallback needs to add
      action_fallback ExMonWeb.FallbackController

      def create(conn, params) do
        params
        |> ExMon.create_trainer()
        |> handle_response(conn)
      end

      defp handle_response({:ok, trainer}, conn) do
        conn
        |> put_status(:created)
        |> render("create.json", trainer: trainer)
      end

      # add this code to push the error forward
      defp handle_response({:error, _changeset} = error, _conn), do: error
    end
    ```
* create __lib/ex_mon_web/controllers/fallback_controller.ex__
  - add the code
    ```elixir
    defmodule ExMonWeb.FallbackController do
      use ExMonWeb, :controller

      # every controller action receives first the connection
      # and second the parameters that the action receives

      # every fallback controller defines a call function that will
      # be responsible for receiving any error that is being pushed forward
      def call(conn, {:error, result}) do
        conn
        # Plug.Conn.put_status(conn, status)
        |> put_status(:bad_request)
        # When we want to render a view that
        # doesn't have the same name as the controller we use put_view
        # Phoenix.Controller.put_view(conn, module) Stores the view for rendering.
        |> put_view(ExMonWeb.ErrorView)
        # Phoenix.Controller.render(conn, template, assigns)
        |> render("400.json", result: result)
      end
    end
    ```
* in the __lib/ex_mon_web/views/error_view.ex__
  - add the code
    ```elixir
    defmodule ExMonWeb.ErrorView do
      use ExMonWeb, :view

      import Ecto.Changeset, only: [traverse_errors: 2]

      # If you want to customize a particular status code
      # for a certain format, you may uncomment below.
      # def render("500.json", _assigns) do
      #   %{errors: %{detail: "Internal Server Error"}}
      # end

      # By default, Phoenix returns the status message from
      # the template name. For example, "404.json" becomes
      # "Not Found".
      def template_not_found(template, _assigns) do
        %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
      end

      def render("400.json", %{result: result}) do
        %{message: translate_errors(result)}
      end

      defp translate_errors(changeset) do
        traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
      end
    end
    ```
### Creating the delete route
* in the __lib/ex_mon.ex__
  - add the code
    ```elixir
    defdelegate delete_trainer(params),
      to: ExMon.Trainer.Delete,
      as: :call
    ```
* understanding __Ecto.UUID.cast()__
  ```bash
  iex> Ecto.UUID.cast("123456")
  :error
  ```
  ```bash
  iex> Ecto.UUID.generate
  "365d003d-2874-47ed-a694-9cb9c6a946d8"
  ```
  ```bash
  iex> Ecto.UUID.cast("365d003d-2874-47ed-a694-9cb9c6a946d8")
  {:ok, "365d003d-2874-47ed-a694-9cb9c6a946d8"}
  ```
* create the __lib/ex_mon/trainer/delete.ex__
  - add the code
    ```elixir
    defmodule ExMon.Trainer.Delete do
      alias ExMon.{Trainer, Repo}

      # id is a string
      def call(id) do
        case Ecto.UUID.cast(id) do
          :error -> {:error, "Invalid ID format!"}
          {:ok, uuid} -> delete(uuid)
        end
      end

      defp delete(uuid) do
        # return a nil or a trainer:
        case fetch_trainer(uuid) do
          nil -> {:error, "Trainer not found!"}
          trainer -> Repo.delete(trainer)
        end
      end

      defp fetch_trainer(uuid), do: Repo.get(Trainer, uuid)
    end
    ```
* deleting the _first trainer_ id: "0459ac19-4e23-4d69-a9fe-5c392739b211"
  - searching all trainers
    ```bash
    iex> ExMon.Repo.all(ExMon.Trainer)
    [debug] QUERY OK source="trainers" db=15.1ms decode=1.7ms queue=1.1ms idle=693.7ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 []
    [
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "0459ac19-4e23-4d69-a9fe-5c392739b211",
        inserted_at: ~N[2021-04-10 10:21:54],
        name: "Maiqui",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$SgXPR4GA6nZkbCseL9NRVA$R4tWwraUkZL4O297MuYs4Du1nBch4t8+DzelAqhCips",
        updated_at: ~N[2021-04-10 10:21:54]
      },
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "cee4f5a7-1795-4aca-8382-9a95a1657072",
        inserted_at: ~N[2021-04-10 17:13:29],
        name: "Maiqui",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$rQ2YWdFrxoaaYFCdlGVQww$R0mGF1zy+2RfsFY61DInqRXmp6m3yX/gIOngPf+uHeA",
        updated_at: ~N[2021-04-10 17:13:29]
      },
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "6fc6c812-7950-4461-8145-8f7259281a71",
        inserted_at: ~N[2021-04-10 17:43:52],
        name: "Ash Ketchum",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
        updated_at: ~N[2021-04-10 17:43:52]
      }
    ]
    ```
  - deleting by passing a _valid id_ as argument
    ```bash
    iex> ExMon.delete_trainer("0459ac19-4e23-4d69-a9fe-5c392739b211")
    [debug] QUERY OK source="trainers" db=1.3ms queue=1.4ms idle=1086.9ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<4, 89, 172, 25, 78, 35, 77, 105, 169, 254, 92, 57, 39, 57, 178, 17>>]
    [debug] QUERY OK db=7.5ms queue=2.0ms idle=1108.3ms
    DELETE FROM "trainers" WHERE "id" = $1 [<<4, 89, 172, 25, 78, 35, 77, 105, 169, 254, 92, 57, 39, 57, 178, 17>>]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:deleted, "trainers">,
      id: "0459ac19-4e23-4d69-a9fe-5c392739b211",
      inserted_at: ~N[2021-04-10 10:21:54],
      name: "Maiqui",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$SgXPR4GA6nZkbCseL9NRVA$R4tWwraUkZL4O297MuYs4Du1nBch4t8+DzelAqhCips",
      updated_at: ~N[2021-04-10 10:21:54]
    }}
    ```
  - trying to delete by passing the _same id_ as argument
    ```bash
    iex> ExMon.delete_trainer("0459ac19-4e23-4d69-a9fe-5c392739b211")
    [debug] QUERY OK source="trainers" db=0.9ms queue=0.1ms idle=1864.0ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<4, 89, 172, 25, 78, 35, 77, 105, 169, 254, 92, 57, 39, 57, 178, 17>>]
    {:error, "Trainer not found!"}
    ```
  - trying to delete by passing an _invalid id_ as argument
    ```bash
    iex> ExMon.delete_trainer("123456")
    {:error, "Invalid ID format!"}
    ```

* placing in the controller: __lib/ex_mon_web/controllers/trainers_controller.ex__
  - add the code
    ```elixir
    def delete(conn, %{"id" => id}) do
      id
      |> ExMon.delete_trainer()
      |> handle_delete(conn)
    end

    defp handle_delete({:ok, _deleted_trainer}, conn) do
      conn
      |> put_status(:no_content)
      |> text("") # returning an empty text
    end

    # push the error forward
    defp handle_delete({:error, _reason} = error, _conn), do: error
    ```
  - searching all trainers again
    ```bash
    iex> ExMon.Repo.all(ExMon.Trainer)
    [debug] QUERY OK source="trainers" db=2.1ms queue=0.1ms idle=1912.4ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 []
    [
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "cee4f5a7-1795-4aca-8382-9a95a1657072",
        inserted_at: ~N[2021-04-10 17:13:29],
        name: "Maiqui",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$rQ2YWdFrxoaaYFCdlGVQww$R0mGF1zy+2RfsFY61DInqRXmp6m3yX/gIOngPf+uHeA",
        updated_at: ~N[2021-04-10 17:13:29]
      },
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "6fc6c812-7950-4461-8145-8f7259281a71",
        inserted_at: ~N[2021-04-10 17:43:52],
        name: "Ash Ketchum",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
        updated_at: ~N[2021-04-10 17:43:52]
      }
    ]
    ```
  - deleting the first trainer using http (id: "cee4f5a7-1795-4aca-8382-9a95a1657072")
    ```bash
    $ http delete http://localhost:4000/api/trainers/cee4f5a7-1795-4aca-8382-9a95a1657072
    HTTP/1.1 204 No Content
    cache-control: max-age=0, private, must-revalidate
    content-type: text/plain; charset=utf-8
    date: Sun, 11 Apr 2021 18:07:42 GMT
    server: Cowboy
    x-request-id: FnTgAZO6CfBaPqUAAAAh
    ```
  - trying to delete using _invalid id_
    - ❌ here we have a problem ❌
      ```bash
      $ http delete http://localhost:4000/api/trainers/123456
      HTTP/1.1 500 Internal Server Error
      cache-control: max-age=0, private, must-revalidate
      content-length: 69118
      content-type: text/html; charset=utf-8
      date: Sun, 11 Apr 2021 18:12:05 GMT
      server: Cowboy
      x-request-id: FnTgPtQtLjDCpWgAAABh

      <!DOCTYPE html>
      <html>
      <head>
          <meta charset="utf-8">
          <title>FunctionClauseError at DELETE /api/trainers/123456</title>
          <meta name="viewport" content="width=device-width">
      ...
      ```
### Handling errors
* in the __lib/ex_mon_web/views/error_view.ex__
  - change the _render_
  ```elixir
  def render("400.json", %{result: %Ecto.Changeset{} = result}) do
    %{message: translate_errors(result)}
  end

  def render("400.json", %{result: message}) do
    %{message: message}
  end
  ```
  - now the error message works "Invalid ID format!"
  ```bash
  $ http delete http://localhost:4000/api/trainers/123456
  HTTP/1.1 400 Bad Request
  cache-control: max-age=0, private, must-revalidate
  content-length: 32
  content-type: application/json; charset=utf-8
  date: Sun, 11 Apr 2021 23:08:40 GMT
  server: Cowboy
  x-request-id: FnTi6lcQn_D9eEQAAAEG

  {
      "message": "Invalid ID format!"
  }
  ```
  - now the error message works "Trainer not_found!"
  ```bash
  $ http delete http://localhost:4000/api/trainers/0459ac19-4e23-4d69-a9fe-5c392739b211
  HTTP/1.1 400 Bad Request
  cache-control: max-age=0, private, must-revalidate
  content-length: 32
  content-type: application/json; charset=utf-8
  date: Sun, 11 Apr 2021 23:13:50 GMT
  server: Cowboy
  x-request-id: FnTjM03m5Qh-fa8AAACB

  {
      "message": "Trainer not found!"
  }
  ```
### Creating the GET trainer
* create __lib/ex_mon/trainer/get.ex__
  - add this code
  ```elixir
    defmodule ExMon.Trainer.Get do
    alias ExMon.{Trainer, Repo}
    alias Ecto.UUID

    def call(id) do # id is a string
      case UUID.cast(id) do
        :error -> {:error, "Invalid ID format!"}
        {:ok, uuid} -> get(uuid)
      end
    end

    defp get(uuid) do
      case Repo.get(Trainer, uuid) do
        nil -> {:error, "Trainer not found!"}
        trainer -> {:ok, trainer}
      end
    end
  end
  ```
* in the __lib/ex_mon.ex__
  - add this code
  ```elixir
  defdelegate fetch_trainer(params),
    to: ExMon.Trainer.Get,
    as: :call
  ```
* testing in IEX
  - searching all trainers
    ```bash
    iex> ExMon.Repo.all(ExMon.Trainer)
    [debug] QUERY OK source="trainers" db=12.7ms decode=1.7ms queue=0.8ms idle=1392.8ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 []
    [
      %ExMon.Trainer{
        __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
        id: "6fc6c812-7950-4461-8145-8f7259281a71",
        inserted_at: ~N[2021-04-10 17:43:52],
        name: "Ash Ketchum",
        password: nil,
        password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
        updated_at: ~N[2021-04-10 17:43:52]
      }
    ]
    ```
  - searching the trainer by id
    ```bash
    iex> ExMon.fetch_trainer("6fc6c812-7950-4461-8145-8f7259281a71")
    [debug] QUERY OK source="trainers" db=0.9ms queue=1.2ms idle=1069.4ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "6fc6c812-7950-4461-8145-8f7259281a71",
      inserted_at: ~N[2021-04-10 17:43:52],
      name: "Ash Ketchum",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
      updated_at: ~N[2021-04-10 17:43:52]
    }}
    ```
  - searching for a trainer that doesn't exist
    ```bash
    iex> ExMon.fetch_trainer("cee4f5a7-1795-4aca-8382-9a95a1657072")
    [debug] QUERY OK source="trainers" db=2.4ms queue=0.1ms idle=1448.5ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<206, 228, 245, 167, 23, 149, 74, 202, 131, 130, 154, 149, 161, 101, 112, 114>>]
    {:error, "Trainer not found!"}
    ```
  - entering an invalid id
    ```bash
    iex> ExMon.fetch_trainer("123456")
    {:error, "Invalid ID format!"}
    ```
### Refactoring our Trainer Controller
* in the __lib/ex_mon_web/controllers/trainers_controller.ex__
  - creating the _show action_
    ```elixir
    def show(conn, %{"id" => id}) do
      id
      |> ExMon.fetch_trainer()
      |> handle_response(conn)
    end
    ```
  - refactoring the *handle_response* to be used by _show_ and _create_
    - add _view_ and _status_
      ```elixir
      defp handle_response({:ok, trainer}, conn, view, status) do
        conn
        |> put_status(status)
        |> render(view, trainer: trainer)
      end

      defp handle_response({:error, _changeset} = error, _conn, _view, _status), do: error
      ```
    - change the __def create()__
      ```elixir
      |> handle_response(conn, "create.json", :created)
      ```
    - change the __def show()__
      ```elixir
      |> handle_response(conn, "show.json", :ok)
      ```
* in the __lib/ex_mon_web/views/trainers_view.ex__
  - create the _show.json_
    ```elixir
    def render(
      "show.json",
      %{trainer: %Trainer{id: id, name: name, inserted_at: inserted_at}}
    ) do
      %{
        id: id,
        name: name,
        inserted_at: inserted_at
      }
    end
    ```
  - searching for a trainer in bash
    ```bash
    $ http get http://localhost:4000/api/trainers/6fc6c812-7950-4461-8145-8f7259281a71
    HTTP/1.1 200 OK
    cache-control: max-age=0, private, must-revalidate
    content-length: 102
    content-type: application/json; charset=utf-8
    date: Mon, 12 Apr 2021 01:33:09 GMT
    server: Cowboy
    x-request-id: FnTpmbfX3zxyocYAAAPE

    {
        "id": "6fc6c812-7950-4461-8145-8f7259281a71",
        "inserted_at": "2021-04-10T17:43:52",
        "name": "Ash Ketchum"
    }
    ```
  - passing an invalid id
    ```bash
    $ http get http://localhost:4000/api/trainers/123456
    HTTP/1.1 400 Bad Request
    cache-control: max-age=0, private, must-revalidate
    content-length: 32
    content-type: application/json; charset=utf-8
    date: Mon, 12 Apr 2021 01:35:01 GMT
    server: Cowboy
    x-request-id: FnTps-fsimRxu0AAAAAH

    {
        "message": "Invalid ID format!"
    }
    ```
  - passing an id that does not exist in the database
    ```bash
    $ http get http://localhost:4000/api/trainers/cee4f5a7-1795-4aca-8382-9a95a1657072
    HTTP/1.1 400 Bad Request
    cache-control: max-age=0, private, must-revalidate
    content-length: 32
    content-type: application/json; charset=utf-8
    date: Mon, 12 Apr 2021 01:37:22 GMT
    server: Cowboy
    x-request-id: FnTp1TTBq4wYsOEAAAPk

    {
        "message": "Trainer not found!"
    }
    ```
### Refactoring our changeset for the update
* in the __lib/ex_mon/trainer.ex__
  - we need to change this code
    ```elixir
    def changeset(params) do
      %__MODULE__{}
      |> cast(params, @required_params)
      |> validate_required(@required_params)
      |> validate_length(:password, min: 6)
      |> put_pass_hash()
    end
    ```
  - for this code
    ```elixir
    def changeset(params), do: create_changeset(%__MODULE__{}, params)
    def changeset(trainer, params), do: create_changeset(trainer, params)

    def create_changeset(module_or_trainer, params) do
      module_or_trainer
      |> cast(params, @required_params)
      |> validate_required(@required_params)
      |> validate_length(:password, min: 6)
      |> put_pass_hash()
    end
    ```
### Creating the update logic
* create __lib/ex_mon/trainer/update.ex__
  - add the code
  ```elixir
  defmodule ExMon.Trainer.Update do
    alias ExMon.{Trainer, Repo}
    alias Ecto.UUID

    def call(%{"id" => uuid} = params) do
      case UUID.cast(uuid) do
        :error -> {:error, "Invalid ID format!"}
        {:ok, _uuid} -> update(params)
      end
    end

    defp update(%{"id" => uuid} = params) do
      case fetch_trainer(uuid) do
        nil -> {:error, "Trainer not found!"}
        trainer -> update_trainer(trainer, params)
      end
    end

    defp fetch_trainer(uuid), do: Repo.get(Trainer, uuid)

    defp update_trainer(trainer, params) do
      trainer
      |> Trainer.changeset(params)
      |> Repo.update()
    end
  end
  ```
* testing
  - searching for a trainer
    ```bash
    iex> ExMon.fetch_trainer("6fc6c812-7950-4461-8145-8f7259281a71")
    [debug] QUERY OK source="trainers" db=0.9ms queue=1.2ms idle=1069.4ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "6fc6c812-7950-4461-8145-8f7259281a71",
      inserted_at: ~N[2021-04-10 17:43:52],
      name: "Ash Ketchum",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$bMZoPwnUMpLOxcXxd49R2A$O0WskxnPMJQmfhvfRFwRVTNwEJk4nNOk6UpbuXyPSLE",
      updated_at: ~N[2021-04-10 17:43:52]
    }}
    ```
  - create the params
    ```bash
    iex> params = %{"id" => "6fc6c812-7950-4461-8145-8f7259281a71", "name" => "Maiqui Tomé", "password" => "12345678"}
    %{
      "id" => "6fc6c812-7950-4461-8145-8f7259281a71",
      "name" => "Maiqui Tomé",
      "password" => "12345678"
    }
    ```
  - updating...
    ```bash
    iex(3)> ExMon.Trainer.Update.call(params)
    [debug] QUERY OK source="trainers" db=2.3ms queue=0.1ms idle=1099.2ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
    [debug] QUERY OK db=2.9ms queue=0.6ms idle=1439.1ms
    UPDATE "trainers" SET "name" = $1, "password_hash" = $2, "updated_at" = $3 WHERE "id" = $4 ["Maiqui Tomé", "$argon2id$v=19$m=131072,t=8,p=4$HtKN4TNv8AIO5DIMz4Ch9g$Cd7FaCIoS2rmmo3u7lzeZWmd4fKvi3SwUX9XOkGWZAU", ~N[2021-04-12 15:40:59], <<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "6fc6c812-7950-4461-8145-8f7259281a71",
      inserted_at: ~N[2021-04-10 17:43:52],
      name: "Maiqui Tomé",
      password: "12345678",
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$HtKN4TNv8AIO5DIMz4Ch9g$Cd7FaCIoS2rmmo3u7lzeZWmd4fKvi3SwUX9XOkGWZAU",
      updated_at: ~N[2021-04-12 15:40:59]
    }}
    ```
  - checking if it has changed at all
    ```bash
    iex(4)> ExMon.fetch_trainer("6fc6c812-7950-4461-8145-8f7259281a71")
    [debug] QUERY OK source="trainers" db=1.2ms idle=1622.6ms
    SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
    {:ok,
    %ExMon.Trainer{
      __meta__: #Ecto.Schema.Metadata<:loaded, "trainers">,
      id: "6fc6c812-7950-4461-8145-8f7259281a71",
      inserted_at: ~N[2021-04-10 17:43:52],
      name: "Maiqui Tomé",
      password: nil,
      password_hash: "$argon2id$v=19$m=131072,t=8,p=4$HtKN4TNv8AIO5DIMz4Ch9g$Cd7FaCIoS2rmmo3u7lzeZWmd4fKvi3SwUX9XOkGWZAU",
      updated_at: ~N[2021-04-12 15:40:59]
    }}
    ```
  - trying to update with blank password
    - params without password
      ```bash
      iex> params = %{"id" => "6fc6c812-7950-4461-8145-8f7259281a71", "name" => "Maiqui Tomé"}
      %{"id" => "6fc6c812-7950-4461-8145-8f7259281a71", "name" => "Maiqui Tomé"}
      ```
    - error when trying to update
      ```bash
      iex> ExMon.Trainer.Update.call(params)
      [debug] QUERY OK source="trainers" db=2.3ms queue=0.1ms idle=1269.8ms
      SELECT t0."id", t0."name", t0."password_hash", t0."inserted_at", t0."updated_at" FROM "trainers" AS t0 WHERE (t0."id" = $1) [<<111, 198, 200, 18, 121, 80, 68, 97, 129, 69, 143, 114, 89, 40, 26, 113>>]
      {:error,
      #Ecto.Changeset<
        action: :update,
        changes: %{},
        errors: [password: {"can't be blank", [validation: :required]}],
        data: #ExMon.Trainer<>,
        valid?: false
      >}
      ```
* in the __lib/ex_mon.ex__
  - add the code
    ```elixir
    defdelegate update_trainer(params),
      to: ExMon.Trainer.Update,
      as: :call
    ```
