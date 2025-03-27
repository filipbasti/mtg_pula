defmodule MtgPulaWeb.TournamentChannelJSON do
  def render("bye.json") do
    %{
      id: nil,
      deck: nil,
      opponents: nil,
      points: nil,
      had_bye: nil,
      dropped: nil,
      tournament_id: nil,
      user_id: nil,
      user: %{
        id: nil,
        full_name: "bye",
        biography: "bye",
        account_id: nil
      }
    }
  end

  def render("user.json", %MtgPula.Users.User{} = user) do
    %{
      id: user.id,
      full_name: user.full_name,
      biography: user.biography,
      account_id: user.account_id
    }
  end

  def render("player.json", %MtgPula.Tournaments.Player{} = player) do
    user_json =
      if Ecto.assoc_loaded?(player.user) do
        render("user.json", player.user)
      else
        nil
      end

    %{
      id: player.id,
      deck: player.deck,
      opponents: player.opponents,
      points: player.points,
      had_bye: player.had_bye,
      dropped: player.dropped,
      tournament_id: player.tournament_id,
      user_id: player.user_id,
      user: user_json
    }
  end

  def render("player_standings.json", %MtgPula.Tournaments.Player{} = player) do
    user_json =
      if Ecto.assoc_loaded?(player.user) do
        render("user.json", player.user)
      else
        nil
      end

    %{
      id: player.id,
      deck: player.deck,
      opponents: player.opponents,
      points: player.points,
      had_bye: player.had_bye,
      dropped: player.dropped,
      tournament_id: player.tournament_id,
      user_id: player.user_id,
      user: user_json,
      omw: player.omw,
      gw: player.gw,
      ogp: player.ogp
    }
  end

  def render("match.json", {player1, player2}) do
    player2 =
      if player2 == :bye do
        render("bye.json")
      else
        render("player.json", player2)
      end

    %{
      player1: render("player.json", player1),
      player2: player2
    }
  end

  def render("match.json", %MtgPula.Tournaments.Match{} = match) do
    player2 =
      if match.player2 == nil do
        render("bye.json")
      else
        render("player.json", match.player2)
      end

    %{
      id: match.id,
      round: match.round,
      player_1_wins: match.player_1_wins,
      player_2_wins: match.player_2_wins,
      is_draw: match.is_draw,
      on_play_id: match.on_play_id,
      player1: render("player.json", match.player1),
      player2: player2,
      winner_id: match.winner_id,
      tournament_id: match.tournament_id
    }
  end

  def render("matches.json", matches) do
    Enum.map(matches, &render("match.json", &1))
  end

  def render("players_start.json", standings) do
    Enum.map(standings, &render("player.json", &1))
  end

  def render("standings.json", standings) do
    Enum.map(standings, &render("player_standings.json", &1))
  end
end
