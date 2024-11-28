defmodule MtgPula.Schema.MatchTest do
 use MtgPula.Support.SchemaCase
  alias MtgPula.Tournaments.Match


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
    {:on_play_id, :binary_id},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [
    :id, :inserted_at, :updated_at, :winner_id, :is_draw, :player_1_wins, :player_2_wins, :on_play_id, :player2_id
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
      valid_params = valid_params(@expected_fields_with_types)
      changeset = Match.changeset(%Match{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _type} <- @expected_fields_with_types do
        actual = Map.get(changes, field)

        cond do
          field == :winner_id ->
            expected_winner =
              cond do
                valid_params["player_1_wins"] > valid_params["player_2_wins"] -> valid_params["player1_id"]
                valid_params["player_2_wins"] > valid_params["player_1_wins"] -> valid_params["player2_id"]
                true -> nil
              end

            assert actual == expected_winner,
                   "Values did not match for field: #{field}\n expected: #{inspect(expected_winner)} \n actual: #{inspect(actual)}"

          field == :is_draw ->
            expected_draw = valid_params["player_1_wins"] == valid_params["player_2_wins"]

            assert actual == expected_draw,
                   "Values did not match for field: #{field}\n expected: #{inspect(expected_draw)} \n actual: #{inspect(actual)}"

          true ->
            expected = valid_params[Atom.to_string(field)]

            assert actual == expected,
                   "Values did not match for field: #{field}\n expected: #{inspect(expected)} \n actual: #{inspect(actual)}"
        end
      end
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = invalid_params(@expected_fields_with_types)
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
