defmodule ExMonWeb.TrainersController do
  use ExMonWeb, :controller

  # create() The first parameter is always conn, a struct which holds information about the request such as the host, path elements, port, query string, and much more.
  # https://hexdocs.pm/phoenix/controllers.html

  def create(conn, params) do
    params
    |> ExMon.create_trainer()
    # every Phoenix action must return a connection:
    |> handle_response(conn)
  end

  defp handle_response({:ok, trainer}, conn) do
    conn
    |> put_status(:created)
    |> render("create.json", trainer: trainer)
  end
end
