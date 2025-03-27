defmodule MtgPula.PlayersTest do
  use MtgPula.Support.DataCase
  alias MtgPula.{Tournaments, Tournaments.Player}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
  end

  describe "create_player/1" do
    test "suvvess: it inserts an player in the db and returns the player" do
      params = Factory.string_params_with_assocs(:player)

      assert {:ok, %Player{} = returned_player} = Tournaments.create_player(params)

      player_from_db = Repo.get(Player, returned_player.id)

      assert returned_player == player_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(player_from_db, schema_field)

        assert actual == expected,
               "Value did not match for field: #{param_field} \n expected: #{expected}, \n actual: #{actual}"
      end
    end

    test "error: returns an error tuple when player can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Tournaments.create_player(missing_params)
    end
  end
end
