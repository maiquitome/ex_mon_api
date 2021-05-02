defmodule ExMon.Trainer.Pokemon.Create do
  @moduledoc """
  Creates the pokemon.
  """
  alias ExMon.Pokemon
  alias ExMon.Trainer.Pokemon, as: TrainerPokemon
  alias ExMon.PokeApi.Client
  alias ExMon.Repo

  def call(%{"name" => pokemon_name} = params) do
    pokemon_name
    |> Client.get_pokemon()
    |> handle_response(params)
  end

  defp handle_response({:ok, body}, params) do
    body
    |> Pokemon.build()
    |> create_pokemon(params)
  end

  defp handle_response({:error, _any} = error, _params), do: error

  defp create_pokemon(%Pokemon{name: name, types: types, weight: weight}, %{
         "nickname" => nickname,
         "trainer_id" => trainer_id
       }) do
    params = %{
      name: name,
      weight: weight,
      types: types,
      nickname: nickname,
      trainer_id: trainer_id
    }

    params
    |> TrainerPokemon.build()
    |> handle_build()
  end

  defp handle_build({:ok, pokemon}), do: Repo.insert(pokemon)
  defp handle_build({:error, %{message: message}}), do: {:error, message}
  defp handle_build({:error, %Ecto.Changeset{}} = error), do: error
end
