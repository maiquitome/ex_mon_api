defmodule ExMonWeb.WelcomeController do
  # Todo controller vai ter uma diferença para um módulo comum.
  # Com esse use, estamos definindo que esse módulo tem todas as
  # funcionalidades de um controller
  use ExMonWeb, :controller

  # Toda a action no phoenix espera 2 parametros:
  #  - A nossa conexão
  #  - E quais parametros vamos receber na nossa rota
  def index(conn, _params) do
    # IO.inspect(conn)
    text(conn, "Welcome to the ExMon API!")
    # Uma coisa nova se compararmos com outros frameworks web é que
    # no Phoenix sempre manipulamos a nossa conexão.
    # O text espera a conexão pq ele devolve a conexão também.
    # Como estamos em uma linguagem funcional, e não podemos manipular um objeto só
    # que é a conexão, então a gente recebe a conexão, módifica e devolve ela.
  end
end
