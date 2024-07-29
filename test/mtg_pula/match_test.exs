defmodule MtgPula.Schema.MatchTest do
  use ExUnit.Case
  alias MtgPula.Tournaments.Match
  alias Ecto.Changeset

  @expected_fields_with_types [
    {:id, :binary_id},
    {:player1_id, :binary_id},
    {:player2_id, :binary_id},
    {:winner_id, :binary_id},
    {:tournament_id, :binary_id},
    {:round, :integer},
    {:player_1_wins, :integer},
    {:player_2_wins, :integer},
    {:is_draw, :boolean},
    {:on_play, :boolean},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [
    :id, :inserted_at, :updated_at, :winner_id, :is_draw, :player_1_wins, :player_2_wins, :on_play
  ]

  describe "fields and types" do
    test "it has the correct field and types" do
      actual_fields_with_types =
        for field <- Match.__schema__(:fields) do
          type = Match.__schema__(:type, field)
          {field, type}
        end
      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "returns a valid changeset when given valid arguments" do
      valid_params = %{
        "id" => Ecto.UUID.generate(),
        "player1_id" => Ecto.UUID.generate(),
        "player2_id" => Ecto.UUID.generate(),
        "winner_id" => Ecto.UUID.generate(),
        "tournament_id" => Ecto.UUID.generate(),
        "round" => 1,
        "player_1_wins" => 3,
        "player_2_wins" => 2,
        "is_draw" => false,
        "on_play" => true,
        "inserted_at" => DateTime.truncate(DateTime.utc_now(), :second),
        "updated_at" => DateTime.truncate(DateTime.utc_now(), :second)
      }
      changeset = Match.changeset(%Match{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @expected_fields_with_types do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected, "Values did not match for field: #{field}\n expected: #{inspect(expected)} \n actual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = %{
        "id" => DateTime.truncate(DateTime.utc_now(), :second),
        "player1_id" => DateTime.truncate(DateTime.utc_now(), :second),
        "player2_id" => DateTime.truncate(DateTime.utc_now(), :second),
        "winner_id" => DateTime.truncate(DateTime.utc_now(), :second),
        "tournament_id" => DateTime.truncate(DateTime.utc_now(), :second),
        "round" => "first",
        "player_1_wins" => "three",
        "player_2_wins" => "two",
        "is_draw" => "maybe",
        "on_play" => "yes",
        "inserted_at" => "not a datetime",
        "updated_at" => "not a datetime"
      }
      assert %Changeset{valid?: false, errors: errors} = Match.changeset(%Match{}, invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field: #{field} is missing from errors"

        {_, meta} = errors[field]
        assert meta[:validation] == :cast, "The validation type, #{meta[:validation]}, is incorrect"
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      invalid_params = %{}
      assert %Changeset{valid?: false, errors: errors} = Match.changeset(%Match{}, invalid_params)

      for {field, _} <- @expected_fields_with_types, field not in @optional do
        assert errors[field], "The field: #{field} is missing from errors"

        {_, meta} = errors[field]
        assert meta[:validation] == :required, "The validation type, #{meta[:validation]}, is incorrect"
      end
      for field <- @optional do
        refute errors[field], "The optional field #{field} is required when it shouldn't be"
      end
    end
  end
end
