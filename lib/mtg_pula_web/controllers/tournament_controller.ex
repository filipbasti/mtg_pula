defmodule MtgPulaWeb.TournamentController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Tournament

  action_fallback MtgPulaWeb.FallbackController

  def index(conn, _params) do
    tournaments = Tournaments.list_tournaments()
    render(conn, :index, tournaments: tournaments)
  end

  def create(conn, %{"tournament" => tournament_params}) do
    updated_params = Map.put(tournament_params, "user_id", conn.assigns.account.user.id)

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
end
