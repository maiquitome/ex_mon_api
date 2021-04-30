defmodule ExMon.Pokemon.Get do
  alias ExMon.PokeApi.Client
  alias ExMon.Pokemon

  @spec call(String) ::
          {:error, any}
          | {:ok, %ExMon.Pokemon{id: number, name: String, types: list, weight: number}}

  def call(pokemon_name) do
    pokemon_name
    |> Client.get_pokemon()
    |> handle_response
  end

  defp handle_response({:ok, body}), do: {:ok, Pokemon.build(body)}
  defp handle_response({:error, _reason} = error), do: error
end
