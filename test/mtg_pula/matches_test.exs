defmodule MtgPula.MatchesTest do
  use MtgPula.Support.DataCase
  alias MtgPula.{Tournaments, Tournaments.Match}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
  end
  describe "create_match/1"do
    test "success: it inserts an match in the db and returns the match"do
      params = Factory.string_params_with_assocs(:match)

      assert {:ok, %Match{} = returned_match} = Tournaments.create_match(params)

      match_from_db = Repo.get(Match, returned_match.id)

      assert returned_match == match_from_db



      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(match_from_db, schema_field)

        assert actual == expected, "Value did not match for field: #{param_field} \n expected: #{expected}, \n actual: #{actual}"


      end
    end

    test "error: returns an error tuple when match can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Tournaments.create_match(missing_params)

    end
    test "player1 is in player2 opponents and vice versa"do
      params = Factory.string_params_with_assocs(:match)

      assert {:ok, %Match{} = returned_match} = Tournaments.create_match(params)
      player1= Tournaments.get_player!(returned_match.player1_id)
      player2 = Tournaments.get_player!(returned_match.player2_id)

      assert Enum.member?(player1.opponents, player2.id), "player2: #{player2.id} is not in #{player1.opponents}"
      assert Enum.member?(player2.opponents, player1.id), "player2: #{player1.id} is not in #{player2.opponents}"

    end

  end



end
