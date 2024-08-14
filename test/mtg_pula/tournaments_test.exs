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

    test "Function returns standings sorted by points, omw, gw and ogp in that order descending" do
      tourney = Factory.insert(:tournament)

     player_list = Factory.insert_list(8, :player, [tournament: tourney, opponents: []])

     Enum.shuffle(player_list)
     |> Enum.chunk_every(2)
     |> Enum.each(fn [player1, player2] ->
      Factory.insert(:match, [player1: player1, player2: player2, winner: player1])
      Repo.update(Player.changeset(player1, %{opponents: [player2.id|player1.opponents]}))
      Repo.update(Player.changeset(player2, %{opponents: [player1.id|player2.opponents]}))

     end)
     Enum.shuffle(player_list)
     |> Enum.chunk_every(2)
     |> Enum.each(fn [player1, player2] ->
      Factory.insert(:match, [player1: player1, player2: player2, winner: player1])
      Repo.update(Player.changeset(player1, %{opponents: [player2.id|player1.opponents]}))
      Repo.update(Player.changeset(player2, %{opponents: [player1.id|player2.opponents]}))

     end)

      assert actual_list = Tournaments.standings_on_tournament(tourney.id)
      IO.inspect(Tournaments.calculate_tiebreakers(actual_list, tourney))


    query = from p in Player,
    where: p.tournament_id == ^tourney.id,
    order_by: [desc: :points]
      expected_list = Repo.all(query)


      assert actual_list == expected_list, "The list is not sorted so these are not final standings "
    end


  end



end
