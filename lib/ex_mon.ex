defmodule ExMon do
  # alias ExMon.Trainer

  defdelegate create_trainer(params),
    to: ExMon.Trainer.Create,
    as: :call
end
