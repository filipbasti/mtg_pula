defmodule MtgPulaWeb.MatchJSON do
  alias MtgPula.Tournaments.Match

  @doc """
  Renders a list of matches.
  """
  def index(%{matches: matches}) do
    %{data: for(match <- matches, do: data(match))}
  end

  @doc """
  Renders a single match.
  """
  def show(%{match: match}) do
    %{data: data(match)}
  end

  defp data(%Match{} = match) do
    %{
      id: match.id,
      round: match.round,
      player_1_wins: match.player_1_wins,
      player_2_wins: match.player_2_wins,
      player1_id: match.player1_id,
      player2_id: match.player2_id,
      on_play_id: match.on_play_id
    }
  end
end
