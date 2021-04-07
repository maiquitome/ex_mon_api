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
    # Using virtual: true
      # This field doesn't exist in the database
    field :password, :string, virtual: true
    timestamps()
  end

  # @required_params [:name, :password_hash]
  @required_params [:name, :password]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_length(:password, min: 6)
    |> put_pass_hash()
  end

  defp put_pass_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
  ) do
    # change(data, changes \\ %{})
    change(changeset, Argon2.add_hash(password))
  end

  # no match
  defp put_pass_hash(changeset), do: changeset
end
