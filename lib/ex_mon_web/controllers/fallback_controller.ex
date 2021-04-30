defmodule ExMonWeb.FallbackController do
  use ExMonWeb, :controller

  # every controller action receives first the connection
  # and second the parameters that the action receives

  # every fallback controller defines a call function that will
  # be responsible for receiving any error that is being pushed forward

  def call(conn, {:error, %{message: error_message, status: status}}) do
    conn
    # Plug.Conn.put_status(conn, status)
    |> put_status(status)
    # When we want to render a view that
    # doesn't have the same name as the controller we use put_view
    # Phoenix.Controller.put_view(conn, module) Stores the view for rendering.
    |> put_view(ExMonWeb.ErrorView)
    # Phoenix.Controller.render(conn, template, assigns)
    |> render("error.json", result: error_message)
  end

  def call(conn, {:error, result}) do
    conn
    # Plug.Conn.put_status(conn, status)
    |> put_status(:bad_request)
    # When we want to render a view that
    # doesn't have the same name as the controller we use put_view
    # Phoenix.Controller.put_view(conn, module) Stores the view for rendering.
    |> put_view(ExMonWeb.ErrorView)
    # Phoenix.Controller.render(conn, template, assigns)
    |> render("error.json", result: result)
  end
end
