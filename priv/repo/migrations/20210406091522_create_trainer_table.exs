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
