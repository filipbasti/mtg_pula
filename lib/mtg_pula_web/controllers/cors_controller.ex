defmodule MtgPulaWeb.CORSController do
  use MtgPulaWeb, :controller

  def options(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-origin", "*") # Change * to your frontend URL in production
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "Authorization, Content-Type, Accept, Origin, User-Agent, Cookie")
    |> send_resp(204, "")
  end
end
