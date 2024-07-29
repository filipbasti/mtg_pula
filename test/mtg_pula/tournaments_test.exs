defmodule MtgPula.Schema.TournamentTest do
  use ExUnit.Case
  alias MtgPula.Tournaments.Tournament
  alias Ecto.Changeset
  @expected_fields_with_types [
    {:id, :binary_id},
    {:user_id, :binary_id},
    {:name, :string},
    {:finished, :boolean},
    {:current_round, :integer},
    {:number_of_rounds, :integer},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [
  :id, :inserted_at, :updated_at, :current_round, :finished
  ]

  describe "fields and types" do
    test "it has the correct field and types" do
    actual_fields_with_types =
      for field <- Tournament.__schema__(:fields) do
        type = Tournament.__schema__(:type, field)
        {field, type}

      end
      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
  end

end

describe "changeset/2" do
  test "returns a valid changeset when given valid arguments"do
    valid_params= %{
      "id" => Ecto.UUID.generate(),
      "user_id" =>Ecto.UUID.generate(),
      "name" => "any name",
      "finished" => true,
      "current_round" => 2,
      "number_of_rounds" => 4,
      "inserted_at" => DateTime.truncate(DateTime.utc_now(), :second),
      "updated_at" => DateTime.truncate(DateTime.utc_now(), :second)
    }
    changeset = Tournament.changeset(%Tournament{}, valid_params)

    assert %Changeset{valid?: true, changes: changes} = changeset

    for{field, _} <- @expected_fields_with_types do
      actual = Map.get(changes, field)
      expected = valid_params[Atom.to_string(field)]


        assert actual == expected, "Values did not match for field: #{field}\n expected: #{inspect(expected)} \n actual: #{inspect(actual)} "

    end

  end

  test "error: returns an error changeset when given un-castable values" do
    invalid_params= %{
      "id" => DateTime.truncate(DateTime.utc_now(), :second),
      "user_id" =>DateTime.truncate(DateTime.utc_now(), :second),
      "name" => DateTime.truncate(DateTime.utc_now(), :second),
      "finished" => DateTime.truncate(DateTime.utc_now(), :second),
      "current_round" => DateTime.truncate(DateTime.utc_now(), :second),
      "number_of_rounds" => DateTime.truncate(DateTime.utc_now(), :second),
      "inserted_at" => "sad sam insertao",
      "updated_at" => "sad sam updateao"
    }
    assert %Changeset{valid?: false, errors: errors} = Tournament.changeset(%Tournament{}, invalid_params)

    for {field, _} <- @expected_fields_with_types do
      assert errors[field], "The field: #{field} is missing from errors"

      {_,meta} = errors[field]
      assert meta[:validation] == :cast, "The validation type, #{meta[:validation]}, is incorrect"
    end


  end
  test "error: returns an error changeset when when required is missing" do
    invalid_params= %{}
    assert %Changeset{valid?: false, errors: errors} = Tournament.changeset(%Tournament{}, invalid_params)

    for {field, _} <- @expected_fields_with_types, field not in @optional do
      assert errors[field], "The field: #{field} is missing from errors"

      {_,meta} = errors[field]
      assert meta[:validation] == :required, "The validation type, #{meta[:validation]}, is incorrect"
    end
    for field <- @optional do
      refute errors[field], "The optional field #{field} is required when it shouldnt be"
    end

  end

end

end
