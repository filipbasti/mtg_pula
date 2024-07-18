defmodule MtgPulaWeb.Auth.Pipeline do

  use Guardian.Plug.Pipeline, otp_app: :mtg_pula,
  module: MtgPulaWeb.Auth.Guardian,
  error_handler: MtgPulaWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
