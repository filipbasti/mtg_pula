defmodule MtgPulaWeb.TournamentController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Tournament
  alias MtgPulaWeb.Tournament.ErrorResponse
  action_fallback MtgPulaWeb.FallbackController

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
  def prepare_next_round(conn, %{"id" => id})do
    case Tournaments.prepare_matches(id)do
      {_tournament, pairings} -> render(conn, :show_pairings, pairings: pairings )
       {:error, :not_found} -> raise ErrorResponse.NotFound, message: "Standings for this tournament not found"
    end

  end
end
