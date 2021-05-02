defmodule ExMon.PokeApi.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://pokeapi.co/api/v2"
  plug Tesla.Middleware.JSON

  @spec get_pokemon(String) :: {:error, any} | {:ok, any}
  @doc """
  returns the entire body of the request:
  "https://pokeapi.co/api/v2/pokemon/pokemon_name"

  ## Examples

  * request made successfully

      iex> ExMon.PokeApi.Client.get_pokemon("scyther")

      {:ok,
      %{
        "abilities" => [
          %{
            "ability" => %{
              "name" => "swarm",
              "url" => "https://pokeapi.co/api/v2/ability/68/"
            },
            "is_hidden" => false,
            "slot" => 1
          },
          ...

  * pokemon that does not exist

      iex> ExMon.PokeApi.Client.get_pokemon("not_exist")

      {:error, %{message: "pokemon not found", status: 404}}

  * no internet

      iex> ExMon.PokeApi.Client.get_pokemon("scyther")

      {:error, :econnrefused}

  """
  def get_pokemon(name) do
    "/pokemon/#{name}"
    |> get()
    |> handle_get()
  end

  defp handle_get({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}

  defp handle_get({:ok, %Tesla.Env{status: 404}}),
    do: {:error, %{message: "pokemon not found", status: 404}}

  defp handle_get({:error, _reason} = error), do: error
end
