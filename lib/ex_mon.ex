defmodule ExMon do
  alias ExMon.{Trainer, Pokemon}

  defdelegate create_trainer(params),
    to: Trainer.Create,
    as: :call

  defdelegate delete_trainer(params),
    to: Trainer.Delete,
    as: :call

  defdelegate fetch_trainer(params),
    to: Trainer.Get,
    as: :call

  defdelegate update_trainer(params),
    to: Trainer.Update,
    as: :call

  @spec fetch_pokemon(String) ::
          {:error, any}
          | {:ok, %ExMon.Pokemon{id: number, name: String, types: list, weight: number}}
  @doc """
  Fetch the pokemon data.

  ## Parameters

    - name: String that represents the name of the pokemon.

  ## Examples

      iex> ExMon.fetch_pokemon("pikachu")
      {:ok, %ExMon.Pokemon{id: 25, name: "pikachu", types: ["electric"], weight: 60}}

      iex> ExMon.fetch_pokemon("banana")
      {:error, "pokemon not found"}

  """
  defdelegate fetch_pokemon(pokemon_name),
    to: Pokemon.Get,
    as: :call
end
