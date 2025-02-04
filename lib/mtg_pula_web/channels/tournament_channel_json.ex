defmodule MtgPulaWeb.TournamentChannelJSON do


  def render("player.json", %MtgPula.Tournaments.Player{} = player) do
    %{
      id: player.id,
      deck: player.deck,
      opponents: player.opponents,
      points: player.points,
      had_bye: player.had_bye,
      dropped: player.dropped,
      tournament_id: player.tournament_id,
      user_id: player.user_id,
      inserted_at: player.inserted_at,
      updated_at: player.updated_at
    }
  end

  def render("match.json", {player1, player2}) do
    %{
      player1: render("player.json", player1),
      player2: render("player.json", player2)
    }
  end

  def render("matches.json", matches) do
    Enum.map(matches, &render("match.json", &1))
  end
end
