defmodule MtgPulaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :mtg_pula

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_mtg_pula_key",
    signing_salt: "N+oRldfJ",
    same_site: "Lax"
  ]

  socket "/socket", MtgPulaWeb.UserSocket,
    websocket: true,
    longpoll: false




  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :mtg_pula,
    gzip: false,
    only: MtgPulaWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :mtg_pula
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug CORSPlug, origin: ["https://interface-mtgpula.onrender.com"]

  plug :options

  defp options(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "https://interface-mtgpula.onrender.com")
    |> put_resp_header("access-control-allow-methods", "GET, POST, OPTIONS, PATCH, PUT")
    |> put_resp_header("access-control-allow-headers", "authorization, content-type")
    |> send_resp(204, "")
  end

  plug MtgPulaWeb.Router
end
