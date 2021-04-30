defmodule ExMon.Pokemon do
  @moduledoc """
  Build up a pokemon's data.
  """

  @keys [:id, :name, :weight, :types]

  @enforce_keys @keys

  defstruct @keys

  @spec build(map) :: %ExMon.Pokemon{id: number(), name: String, types: list, weight: number()}
  @doc """
  Returns a struct with pokemon data.

  ## Examples

      iex> {:ok, pokemon} = ExMon.PokeApi.Client.get_pokemon("scyther")

      iex> ExMon.Pokemon.build(pokemon)
      %ExMon.Pokemon{id: 123, name: "scyther", types: ["bug", "flying"], weight: 560}

  """
  def build(%{"id" => id, "name" => name, "weight" => weight, "types" => types_list}) do
    %__MODULE__{
      id: id,
      name: name,
      weight: weight,
      types: parse_types(types_list)
    }
  end

  ### parse_types(types) ?????
  #
  ### getting the pokemon:
  #
  # iex> ExMon.PokeApi.Client.get_pokemon("scyther")
  #
  ### TURN THIS:
  #       "types" => [
  #         %{
  #           "slot" => 1,
  #           "type" => %{
  #             "name" => "bug",
  #             "url" => "https://pokeapi.co/api/v2/type/7/"
  #           }
  #         },
  #         %{
  #           "slot" => 2,
  #           "type" => %{
  #             "name" => "flying",
  #             "url" => "https://pokeapi.co/api/v2/type/3/"
  #           }
  #         }
  #       ]
  ### INTO THIS:
  #       ["bug", "flying"]

  # What is parse????
  # What does parse mean????
  #
  # parse = analisar, interpretar
  # O ato de "parsear", nada mais é do que "tranformar" do tipo A para o tipo B.
  defp parse_types(types), do: Enum.map(types, fn item -> item["type"]["name"] end)
end
