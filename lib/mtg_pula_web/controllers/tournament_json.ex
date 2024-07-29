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
end
