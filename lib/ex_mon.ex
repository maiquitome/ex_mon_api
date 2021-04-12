defmodule ExMon do
  # alias ExMon.Trainer

  defdelegate create_trainer(params),
    to: ExMon.Trainer.Create,
    as: :call

  defdelegate delete_trainer(params),
    to: ExMon.Trainer.Delete,
    as: :call

  defdelegate fetch_trainer(params),
    to: ExMon.Trainer.Get,
    as: :call

  defdelegate update_trainer(params),
    to: ExMon.Trainer.Update,
    as: :call
end
