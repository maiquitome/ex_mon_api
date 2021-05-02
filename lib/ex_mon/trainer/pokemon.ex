defmodule ExMon.Trainer.Pokemon do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExMon.Repo
  alias ExMon.Trainer

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "pokemons" do
    # field :id, :uuid, primary_key: true
    field :name, :string
    field :nickname, :string
    field :weight, :integer
    field :types, {:array, :string}

    belongs_to :trainer, ExMon.Trainer

    timestamps()
  end

  @permitted_fields [
    :name,
    :nickname,
    :weight,
    :types,
    :trainer_id
  ]
  @required_fiels [
    :name,
    :nickname,
    :weight,
    :types,
    :trainer_id
  ]

  @spec build(map) :: {:error, map} | {:ok, map}
  @doc """
  Validates the pokemon information to be sent to the database.

  ## Examples

      iex> params = %{name: "pikachu", nickname: "oi", weight: 50, types: ["electric"], trainer_id: "34f55bd0-179e-4442-8c9d-6d820e74a8d1"}
      %{
        name: "pikachu",
        nickname: "oi",
        trainer_id: "34f55bd0-179e-4442-8c9d-6d820e74a8d1",
        types: ["electric"],
        weight: 50
      }

      iex> ExMon.Trainer.Pokemon.build(params)
      {:ok,
      %ExMon.Trainer.Pokemon{
        __meta__: #Ecto.Schema.Metadata<:built, "pokemons">,
        id: nil,
        inserted_at: nil,
        name: "pikachu",
        nickname: "oi",
        trainer: #Ecto.Association.NotLoaded<association :trainer is not loaded>,
        trainer_id: "34f55bd0-179e-4442-8c9d-6d820e74a8d1",
        types: ["electric"],
        updated_at: nil,
        weight: 50
      }}
  """

  def build(map_with_changes) do
    map_with_changes
    |> changeset()
    # emulates operations such as Repo.insert
    |> apply_action(:insert)
    |> handle_errors()
  end

  defp handle_errors({:error, params}), do: {:error, params}

  defp handle_errors({:ok, %{trainer_id: trainer_id} = params}) do
    Repo.get(Trainer, trainer_id)
    |> handle_trainer(params)

    # if Repo.get(Trainer, trainer_id) do
    #   {:ok, params}
    # else
    #   {:error, %{message: "trainer does not exist"}}
    # end
  end

  defp handle_trainer({:ok, _schema}, params), do: {:ok, params}

  defp handle_trainer({:error, _changeset}, _params),
    do: {:error, %{message: "trainer does not exist"}}

  def changeset(map_with_changes) do
    %__MODULE__{}
    |> cast(map_with_changes, @permitted_fields)
    |> validate_required(@required_fiels)
    |> validate_length(:nickname, min: 2)
  end
end
