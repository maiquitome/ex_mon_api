defmodule ExMonWeb.PokemonsController do
  use ExMonWeb, :controller

  action_fallback ExMonWeb.FallbackController

  def show(conn, %{"poke_name" => pokemon_name}) do
    pokemon_name
    |> ExMon.fetch_pokemon()
    |> handle_response(conn)
  end

  defp handle_response({:ok, pokemon}, conn) do
    conn
    |> Plug.Conn.put_status(:ok)
    |> Phoenix.Controller.json(pokemon)
  end

  defp handle_response({:error, _reason} = error, _conn), do: error
end
