defmodule MtgPula.TournamentsTest do
  use MtgPula.Support.DataCase
  alias MtgPula.{Tournaments, Tournaments.Tournament, Tournaments.Player, Tournaments.Match}
  import Ecto.Query

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
  end

  describe "drop_player/1" do
    test "test dropping a player" do
      tourney = Factory.insert(:tournament)

      players =
        Factory.insert_list(9, :player,
          tournament: tourney,
          opponents: [],
          points: 0,
          had_bye: false
        )

      first_player = List.first(players)

      {tourney, list} = Tournaments.pair_next_round(tourney.id)

      list = List.delete_at(list, -1)

      list
      |> Enum.each(fn {player1, player2} ->
        Factory.insert(:match,
          player1: player1,
          player2: player2,
          winner: player1,
          is_draw: false,
          player_1_wins: 2,
          player_2_wins: 1,
          tournament: tourney
        )

        Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
        Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))
      end)

      assert _dropped_player = Tournaments.drop_player(first_player.id)
      {tourney, list2} = Tournaments.pair_next_round(tourney.id)

      list2 = List.delete_at(list2, -1)

      list2
      |> Enum.each(fn {player1, player2} ->
        Factory.insert(:match,
          player1: player1,
          player2: player2,
          winner: player1,
          is_draw: false,
          player_1_wins: 2,
          player_2_wins: 1,
          tournament: tourney
        )

        Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
        Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))
      end)
    end
  end

  describe "pair_next_round/1" do
    test "assigns bye if there is uneven players" do
      tourney = Factory.insert(:tournament)

      Factory.insert_list(9, :player,
        tournament: tourney,
        opponents: [],
        points: 0,
        had_bye: false
      )

      {tourney, list} = Tournaments.pair_next_round(tourney.id)
      assert {_player, :bye} = List.last(list)

      list = List.delete_at(list, -1)

      list
      |> Enum.each(fn {player1, player2} ->
        Factory.insert(:match,
          player1: player1,
          player2: player2,
          winner: player1,
          is_draw: false,
          player_1_wins: 2,
          player_2_wins: 1,
          tournament: tourney
        )

        Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
        Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))
      end)

      {tourney, list2} = Tournaments.pair_next_round(tourney.id)

      assert {_player, :bye} = List.last(list2)
      list2 = List.delete_at(list2, -1)

      list2
      |> Enum.each(fn {player1, player2} ->
        Factory.insert(:match,
          player1: player1,
          player2: player2,
          winner: player1,
          is_draw: false,
          player_1_wins: 2,
          player_2_wins: 1,
          tournament: tourney
        )

        Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
        Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))
      end)

      # IO.inspect(Tournaments.standings_on_tournament(tourney.id))
    end
  end

  describe "current_matches/1" do
    test "testing if current matches return current round " do
      tourney = Factory.insert(:tournament)
      player_count = 9

      Factory.insert_list(player_count, :player,
        tournament: tourney,
        opponents: [],
        points: 0,
        had_bye: false
      )

      assert {:ok, tourney, _matches} = Tournaments.prepare_matches(tourney.id)

      q =
        from m in Match,
          where: m.tournament_id == ^tourney.id and ^tourney.current_round == m.round,
          preload: [player1: :user, player2: :user]

      current_matches_expected = Repo.all(q)

      {:ok, actual_current_matches} = Tournaments.current_matches(tourney.id)

      assert current_matches_expected == actual_current_matches

      assert {:ok, tourney, _matches} = Tournaments.prepare_matches(tourney.id)

      # check next round
      q =
        from m in Match,
          where: m.tournament_id == ^tourney.id and ^tourney.current_round == m.round,
          preload: [player1: :user, player2: :user]

      current_matches_expected = Repo.all(q)

      {:ok, actual_current_matches} = Tournaments.current_matches(tourney.id)

      assert current_matches_expected == actual_current_matches, "second match fail"
    end
  end

  describe "standings_on_tournament/1" do
    test "Function returns standings sorted by points, omw, gw and ogp in that order descending" do
      tourney = Factory.insert(:tournament)

      Factory.insert_list(8, :player, tournament: tourney, opponents: [], points: 0)
      |> Enum.chunk_every(2)
      |> Enum.each(fn [player1, player2] ->
        Factory.insert(:match,
          player1: player1,
          player2: player2,
          winner: player1,
          is_draw: false,
          player_1_wins: 2,
          player_2_wins: 1,
          tournament: tourney
        )

        Repo.update(Player.changeset(player1, %{opponents: player1.opponents ++ [player2.id]}))
        Repo.update(Player.changeset(player2, %{opponents: player2.opponents ++ [player1.id]}))
      end)

      assert {:ok, actual_list} = Tournaments.standings_on_tournament(tourney.id)

      query =
        from p in Player,
          where: p.tournament_id == ^tourney.id

      standings = Repo.all(query)
      Repo.get!(Tournament, tourney.id)

      expected_list =
        standings
        |> Tournaments.calculate_tiebreakers(tourney)

      expected_list =
        Enum.sort_by(expected_list, &{&1.points, &1.omw, &1.gw, &1.ogp, &1.id}, :desc)

      assert Enum.map(actual_list, &remove_timestamps/1) ==
               Enum.map(expected_list, &remove_timestamps/1)
    end
  end

  describe "prepare_matches/1" do
    test "Testing preparing matches so that all players are paired" do
      tourney = Factory.insert(:tournament)
      player_count = 9

      expected_players =
        Factory.insert_list(player_count, :player,
          tournament: tourney,
          opponents: [],
          points: 0,
          had_bye: false
        )

      assert {:ok, _tourney, matches} = Tournaments.prepare_matches(tourney.id)

      paired_players =
        Enum.reduce(matches, [], fn y, acc ->
          {player1, player2} = y

          if player2 == :bye do
            acc ++ [player1.id]
          else
            acc ++ [player1.id] ++ [player2.id]
          end
        end)

      expected_players =
        Enum.reduce(expected_players, [], fn y, acc ->
          acc ++ [y.id]
        end)

      assert Enum.sort(paired_players) == Enum.sort(expected_players)
    end
  end

  describe "create_tournament/1" do
    test "success: it inserts an tournament in the db and returns the tournament" do
      params = Factory.string_params_with_assocs(:tournament)

      assert {:ok, %Tournament{} = returned_tournament} = Tournaments.create_tournament(params)

      tournament_from_db = Repo.get(Tournament, returned_tournament.id)

      assert returned_tournament == tournament_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(tournament_from_db, schema_field)

        assert actual == expected,
               "Value did not match for field: #{param_field} \n expected: #{expected}, \n actual: #{actual}"
      end
    end

    test "error: returns an error tuple when tournament can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Tournaments.create_tournament(missing_params)
    end

    def remove_timestamps(player) do
      Map.drop(player, [:inserted_at, :updated_at])
    end
  end

  test "join_code is generated if not provided" do
    params = Factory.string_params_with_assocs(:tournament)
    assert {:ok, %Tournament{} = returned_tournament} = Tournaments.create_tournament(params)
    assert returned_tournament.join_code != nil
    assert String.length(returned_tournament.join_code) == 6
  end
end
