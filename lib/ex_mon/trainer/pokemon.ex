defmodule ExMon.Trainer.Pokemon do
  use Ecto.Schema
  import Ecto.Changeset

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

  @spec build(map) :: {:error, Ecto.Changeset.t()} | {:ok, map}

  def build(map_with_changes) do
    map_with_changes
    |> changeset()
    # emulates operations such as Repo.insert
    |> apply_action(:insert)
  end

  def changeset(map_with_changes) do
    %__MODULE__{}
    |> cast(map_with_changes, @permitted_fields)
    |> validate_required(@required_fiels)
    |> validate_length(:nickname, min: 2)
  end
end
