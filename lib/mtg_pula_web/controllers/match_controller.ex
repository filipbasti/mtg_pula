defmodule MtgPulaWeb.MatchController do
  use MtgPulaWeb, :controller

  alias MtgPula.Tournaments
  alias MtgPula.Tournaments.Match


  def update_score_and_play(conn, %{"id" => id, "match" => match_params}) do
    match = Tournaments.get_match!(id)

    with {:ok, %Match{} = match} <- Tournaments.update_match(match, match_params) do
      render(conn, :show, match: match)
    end
  end



end
