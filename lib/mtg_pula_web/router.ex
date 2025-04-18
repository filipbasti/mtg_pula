defmodule MtgPulaWeb.Router do
  use MtgPulaWeb, :router
  use Plug.ErrorHandler

  defp handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  defp handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  defp handle_errors(conn, %{
         reason: %MtgPulaWeb.Auth.ErrorResponse.Unauthorized{message: message}
       }) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: message})
    |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug MtgPulaWeb.Auth.Pipeline
    plug MtgPulaWeb.Auth.SetAccount
  end

  scope "/api", MtgPulaWeb do
    pipe_through :api

    get "/", DeafaultController, :index
    post "/accounts/create", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in
    get "/tournaments/standings/by_id/:id", TournamentController, :show_standings
    get "/tournaments", TournamentController, :index
    get "/tournaments/matches/by_join_code/:join_code", TournamentController, :tournament_matches
  end

  scope "/api", MtgPulaWeb do
    pipe_through [:api, :auth]
    get "/accounts/by_id/:id", AccountController, :show
    get "/accounts/current", AccountController, :current_account
    patch "/accounts/update", AccountController, :update
    post "/accounts/sign_out", AccountController, :sign_out
    post "/accounts/refresh_session", AccountController, :refresh_session
    put "/users/update", UserController, :update
    post "/tournaments/create", TournamentController, :create
    post "/tournaments/add_player", PlayerController, :create
    get "/tournaments/prepare_round/:tournament_id", TournamentController, :prepare_next_round
    get "/tournaments/current_matches/:tournament_id", TournamentController, :current_matches
    patch "/tournaments/matches/:id", MatchController, :update_score_and_play
  end
end
