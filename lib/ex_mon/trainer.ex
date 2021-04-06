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
    |> validate_length(:password_hash, min: 6)
  end
end
