defmodule MtgPula.Schema.PlayerTest do
  use ExUnit.Case
  alias MtgPula.Tournaments.Player
  alias Ecto.Changeset
  @expected_fields_with_types [
    {:id, :binary_id},
   {:deck, :string},
   {:opponents, {:array, Ecto.UUID}},
   {:points, :integer},
    {:had_bye, :boolean},
   {:tournament_id, :binary_id},
   {:user_id, :binary_id},
   {:inserted_at, :utc_datetime},
   {:updated_at, :utc_datetime}
  ]

  @optional [
  :id, :had_bye, :points, :inserted_at, :updated_at,
  ]

  describe "fields and types" do
    test "it has the correct field and types" do
    actual_fields_with_types =
      for field <- Player.__schema__(:fields) do
        type = Player.__schema__(:type, field)
        {field, type}

      end
      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
  end

end

describe "changeset/2" do

  test "returns a valid changeset when given valid arguments"do
    valid_params = %{
      "id" => Ecto.UUID.generate(),
      "deck" => "Blue-White Control",
      "opponents" => [Ecto.UUID.generate(), Ecto.UUID.generate()],
      "points" => 12,
      "had_bye" => false,
      "tournament_id" => Ecto.UUID.generate(),
      "user_id" => Ecto.UUID.generate(),
      "inserted_at" => DateTime.truncate(DateTime.utc_now(), :second),
      "updated_at" => DateTime.truncate(DateTime.utc_now(), :second)
    }
    changeset = Player.changeset(%Player{}, valid_params)

    assert %Changeset{valid?: true, changes: changes} = changeset

    for{field, _} <- @expected_fields_with_types do
      actual = Map.get(changes, field)
      expected = valid_params[Atom.to_string(field)]


        assert actual == expected, "Values did not match for field: #{field}\n expected: #{inspect(expected)} \n actual: #{inspect(actual)} "

    end

  end

  test "error: returns an error changeset when given un-castable values" do
    invalid_params = %{
      "id" => DateTime.truncate(DateTime.utc_now(), :second),  # Should be a valid UUID
      "deck" => 123,  # Should be a string
      "opponents" => "not-an-array-of-uuids",  # Should be an array of UUIDs
      "points" => "twelve",  # Should be an integer
      "had_bye" => "yes",  # Should be a boolean
      "tournament_id" => DateTime.truncate(DateTime.utc_now(), :second),  # Should be a valid UUID
      "user_id" => 456,  # Should be a valid UUID
      "inserted_at" => 2411142,  # Should be a UTC datetime
      "updated_at" => 789  # Should be a UTC datetime
    }
    assert %Changeset{valid?: false, errors: errors} = Player.changeset(%Player{}, invalid_params)

    for {field, _} <- @expected_fields_with_types do
      assert errors[field], "The field: #{field} is missing from errors"

      {_,meta} = errors[field]
      assert meta[:validation] == :cast, "The validation type, #{meta[:validation]}, is incorrect"
    end


  end

  test "error: returns an error changeset when when required is missing" do
    invalid_params= %{}
    assert %Changeset{valid?: false, errors: errors} = Player.changeset(%Player{}, invalid_params)

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
