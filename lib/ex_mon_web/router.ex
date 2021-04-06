defmodule ExMonWeb.Router do
  use ExMonWeb, :router

  # Esse pipeline define que todas as rotas que utilizarem esse pipeline só
  # aceitaram o formato json
  pipeline :api do
    plug :accepts, ["json"]
    # O plug é uma fatia de código que pega a sua conexão e modifica essa conexão, antes
    # da requisição chegar na action do controller.
    # É quase como se fosse um middleware, mas não é um middleware porque ele não atua
    # na entrada e saída, só na entrada
  end

  # Todas as rotas criadas aqui dentro terão esse endereço:
  # http://localhost:4000/api/o_nome_da_rota
  scope "/api", ExMonWeb do
    pipe_through :api
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ExMonWeb.Telemetry
    end
  end

  # Não tem problema criar um novo com o mesmo nome
  scope "/", ExMonWeb do
    # pipe_through: Apenas requisições que aceitem json
    pipe_through :api

    # :index -> action
    get "/", WelcomeController, :index

    ### Quando usamos resources, não é preciso informar a action
    ### pois é criado automaticamente:
    ###  - um show pro get
    ###  - um create pro post
    ###  - um update pro put
    ###  - e um delete pro delete
    # resources "/nome_da_rota", WelcomeController
  end
end
