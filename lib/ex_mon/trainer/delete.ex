defmodule ExMon.Trainer.Delete do
  alias ExMon.{Trainer, Repo}
  alias Ecto.UUID

  def call(id) do # id is a string
    case UUID.cast(id) do
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
