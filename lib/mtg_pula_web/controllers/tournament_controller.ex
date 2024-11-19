defmodule MtgPulaWeb.TournamentController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Tournament
  alias MtgPulaWeb.Tournament.ErrorResponse
  action_fallback MtgPulaWeb.FallbackController

  import MtgPulaWeb.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update, :delete, :prepare_next_round]
  def index(conn, _params) do
    tournaments = Tournaments.list_tournaments()
    render(conn, :index, tournaments: tournaments)
  end

  def create(conn, %{"tournament" => tournament_params}) do
    updated_params = tournament_params
    |> Map.put("user_id", conn.assigns.account.user.id)
    |> Map.put("current_round", 0)

    with {:ok, %Tournament{} = tournament} <- Tournaments.create_tournament(updated_params) do
      conn
      |> put_status(:created)
      |> render(:show, tournament: tournament)
    end
  end

  def show(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)
    render(conn, :show, tournament: tournament)
  end

  def update(conn, %{"id" => id, "tournament" => tournament_params}) do
    tournament = Tournaments.get_tournament!(id)

    with {:ok, %Tournament{} = tournament} <- Tournaments.update_tournament(tournament, tournament_params) do
      render(conn, :show, tournament: tournament)
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament = Tournaments.get_tournament!(id)

    with {:ok, %Tournament{}} <- Tournaments.delete_tournament(tournament) do
      send_resp(conn, :no_content, "")
    end
  end

  def show_standings(conn, %{"id" => id}) do
    IO.inspect(id)
 case Tournaments.standings_on_tournament(id)do
    {:ok, standings} -> render(conn, :show_standings, standings: standings)
    {:error, :not_found} -> raise ErrorResponse.NotFound, message: "Standings for this tournament not found"

 end


  end
  def prepare_next_round(conn,  %{"tournament_id" => tournament_id})do
    case Tournaments.prepare_matches(tournament_id)do

       {:error, :not_found} -> raise ErrorResponse.NotFound, message: "Standings for this tournament not found"
       {:error, :finished_tourney} -> raise ErrorResponse.Finished, message: "This tournament is already finished"
        {_tournament, pairings} -> render(conn, :show_pairings, pairings: pairings )
    end

  end

  def current_matches(conn, %{"tournament_id" => tournament_id})do
    case Tournaments.current_matches(tournament_id)do
       {:error, :not_found} -> raise ErrorResponse.NotFound, message: "Pairings for this tournament not found"
        {_tournament, pairings} -> render(conn, :show_matches, pairings: pairings )
    end

  end
end
