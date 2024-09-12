defmodule MtgPulaWeb.MatchController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Match

  def update_score_and_play(conn, %{"id" => id, "match" => match_params}) do
    match = Tournaments.get_match!(id)
    params = %{
      player_1_wins: match_params.player_1_wins,
      player_2_wins: match_params.player_2_wins,
      on_play_id: match_params.on_play_id
    }
    with {:ok, %Match{} = match} <- Tournaments.update_match(match, params) do
      render(conn, :show, match: match)
    end
  end



end
