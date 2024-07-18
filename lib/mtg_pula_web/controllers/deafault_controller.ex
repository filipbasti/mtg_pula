defmodule MtgPulaWeb.DeafaultController do
  use MtgPulaWeb, :controller
  def index(conn, _params)do
    text conn, "The Real Deal is LIVE"
  end
end
