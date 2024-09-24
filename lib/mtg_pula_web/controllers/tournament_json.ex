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

  def show_pairings(%{pairings: pairings })do
    reduced = Enum.reduce(pairings, [], fn {player1, player2}, acc ->
      if player2 ==:bye do
        acc ++ [%{
          player1_id: player1.id,
          player1_fullname: player1.user.full_name,
          player2_id: :bye,

          }]
        else
          acc ++ [%{
            player1_id: player1.id,
            player1_fullname: player1.user.full_name,
            player2_id: player2.id,
            player2_fullname: player2.user.full_name

            }]
       end



    end)
    %{data: reduced}

  end

  def show_matches(%{pairings: pairings })do
    reduced = Enum.reduce(pairings, [], fn x, acc ->
      if x.player2 ==:bye do
        acc ++ [%{
          player1_id: x.player1.id,
          player1_fullname: x.player1.user.full_name,
          player2_id: :bye,

          }]
        else
          acc ++ [%{
            player1_id: x.player1.id,
            player1_fullname: x.player1.user.full_name,
            player2_id: x.player2.id,
            player2_fullname: x.player2.user.full_name

            }]
       end



    end)
    %{data: reduced}

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
      ogp: x.ogp,
      opponents: x.opponents
      }]


  end)
  %{data: reduced}
  end



end
