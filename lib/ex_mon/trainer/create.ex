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
