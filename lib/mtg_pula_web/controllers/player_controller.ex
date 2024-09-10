defmodule MtgPulaWeb.PlayerController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Player

  action_fallback MtgPulaWeb.FallbackController

  def index(conn, _params) do
    players = Tournaments.list_players()
    render(conn, :index, players: players)
  end

  def create(conn, %{"player" => player_params}) do
    with {:ok, %Player{} = player} <- Tournaments.create_player(player_params) do
      conn
      |> put_status(:created)

      |> render(:show, player: player)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Tournaments.get_player!(id)
    render(conn, :show, player: player)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Tournaments.get_player!(id)

    with {:ok, %Player{} = player} <- Tournaments.update_player(player, player_params) do
      render(conn, :show, player: player)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Tournaments.get_player!(id)

    with {:ok, %Player{}} <- Tournaments.delete_player(player) do
      send_resp(conn, :no_content, "")
    end
  end
end
