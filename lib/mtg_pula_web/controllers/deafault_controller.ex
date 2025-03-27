defmodule MtgPulaWeb.DeafaultController do
  use MtgPulaWeb, :controller

  def index(conn, _params) do
    text(conn, "MTG PULA IS LIVE!")
  end
end
