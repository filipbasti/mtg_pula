defmodule MtgPulaWeb.PlayerJSON do
  alias MtgPula.Tournaments.Player

  @doc """
  Renders a list of players.
  """
  def index(%{players: players}) do
    %{data: for(player <- players, do: data(player))}
  end

  @doc """
  Renders a single player.
  """
  def show(%{player: player}) do
    %{data: data(player)}
  end

  defp data(%Player{} = player) do
    %{
      id: player.id,
      deck: player.deck,
      opponents: player.opponents,
      points: player.points,
      had_bye: player.had_bye
    }
  end
end
