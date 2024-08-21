defmodule MtgPula.TournamentsTest do
  use MtgPula.Support.DataCase
  alias MtgPula.{Tournaments, Tournaments.Tournament, Tournaments.Player}
  import Ecto.Query

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
  end
  describe "create_tournament/1"do
    test "suvvess: it inserts an tournament in the db and returns the tournament"do
      params = Factory.string_params_with_assocs(:tournament)

      assert {:ok, %Tournament{} = returned_tournament} = Tournaments.create_tournament(params)

      tournament_from_db = Repo.get(Tournament, returned_tournament.id)

      assert returned_tournament == tournament_from_db



      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(tournament_from_db, schema_field)

        assert actual == expected, "Value did not match for field: #{param_field} \n expected: #{expected}, \n actual: #{actual}"


      end
    end

    test "error: returns an error tuple when tournament can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Tournaments.create_tournament(missing_params)

    end

    test "assigns bye if there is uneven players"do
      tourney = Factory.insert(:tournament)

     Factory.insert_list(9, :player, [tournament: tourney, opponents: [], points: 0, had_bye: false])
    list = Tournaments.pair_next_round(tourney.id)
    assert {_player, :bye} =List.last(list)

    list = List.delete_at(list, -1)
      list
     |> Enum.each(fn {player1, player2} ->
   Factory.insert(:match, player1: player1, player2: player2, winner: player1, is_draw: false, player_1_wins: 2, player_2_wins: 1 )

      Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
      Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))

     end)
     list2 = Tournaments.pair_next_round(tourney.id)
     Io.inspect(list2)





    end

    def remove_timestamps(player) do
      Map.drop(player, [:inserted_at, :updated_at])
    end

    test "Function returns standings sorted by points, omw, gw and ogp in that order descending" do
      tourney = Factory.insert(:tournament)

     player_list = Factory.insert_list(8, :player, [tournament: tourney, opponents: [], points: 0])

     Enum.shuffle(player_list)
     |> Enum.chunk_every(2)
     |> Enum.each(fn [player1, player2] ->
    Factory.insert(:match, player1: player1, player2: player2, winner: player1, is_draw: false, player_1_wins: 2, player_2_wins: 1 )



      Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
      Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))

     end)




      assert actual_list = Tournaments.standings_on_tournament(tourney.id)



        query = from p in Player,
        where: p.tournament_id == ^tourney.id

       standings = Repo.all(query)
      Repo.get!(Tournament, tourney.id)
      expected_list = standings
      |> Tournaments.calculate_tiebreakers(tourney)

      expected_list = Enum.sort_by(expected_list, &{&1.points, &1.omw, &1.gw, &1.ogp}, :desc)




        assert Enum.map(actual_list, &remove_timestamps/1) == Enum.map(expected_list, &remove_timestamps/1)
    end


  end



end
