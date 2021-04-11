defmodule ExMonWeb.TrainersController do
  use ExMonWeb, :controller

  # every controller that uses fallback needs to add
  action_fallback ExMonWeb.FallbackController

  def create(conn, params) do
    params
    |> ExMon.create_trainer()
    |> handle_response(conn)
  end

  defp handle_response({:ok, trainer}, conn) do
    conn
    |> put_status(:created)
    |> render("create.json", trainer: trainer)
  end

  # add this code to push the error forward
  defp handle_response({:error, _changeset} = error, _conn), do: error
end
