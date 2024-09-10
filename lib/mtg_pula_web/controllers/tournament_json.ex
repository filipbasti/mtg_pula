defmodule MtgPulaWeb.TournamentJSON do
  alias MtgPula.Tournaments.Tournament

  @doc """
  Renders a list of tournaments.
  """
  def index(%{tournaments: tournaments}) do
    %{data: for(tournament <- tournaments, do: data(tournament))}
  end

  @doc """
  Renders a single tournament.
  """
  def show(%{tournament: tournament}) do
    %{data: data(tournament)}
  end

  defp data(%Tournament{} = tournament) do
    %{
      id: tournament.id,
      name: tournament.name,
      current_round: tournament.current_round,
      number_of_rounds: tournament.number_of_rounds,
      finished: tournament.finished
    }
  end


  def show_standings(%{standings: standings})do
  reduced = Enum.reduce(standings, [], fn x, acc ->

    acc ++ [%{
      id: x.id,
      user_id: x.user_id,
      full_name: x.user.full_name,
      deck: x.deck,
      points: x.points,
      omw: x.omw,
      gw: x.gw,
      ogp: x.ogp
      }]


  end)
  %{data: reduced}
  end
end
