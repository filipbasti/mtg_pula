defmodule MtgPula.Tournaments.Match do
  use Ecto.Schema
  import Ecto.Changeset

  @optional_fields [:id, :inserted_at, :updated_at, :is_draw, :player_1_wins, :player_2_wins, :on_play_id, :winner_id, :player2_id]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "matches" do
    field :round, :integer
    field :player_1_wins, :integer, default: 0
    field :player_2_wins, :integer, default: 0
    field :is_draw, :boolean

    belongs_to :on_play, MtgPula.Tournaments.Player, foreign_key: :on_play_id, type: :binary_id
    belongs_to :player1, MtgPula.Tournaments.Player, foreign_key: :player1_id, type: :binary_id
    belongs_to :player2, MtgPula.Tournaments.Player, foreign_key: :player2_id, type: :binary_id
    belongs_to :winner, MtgPula.Tournaments.Player, foreign_key: :winner_id, type: :binary_id
    belongs_to :tournament, MtgPula.Tournaments.Tournament, foreign_key: :tournament_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  defp calculate_winner(changeset) do
    player_1_wins = get_field(changeset, :player_1_wins, 0)
    player_2_wins = get_field(changeset, :player_2_wins, 0)
    player1_id = get_field(changeset, :player1_id)
    player2_id = get_field(changeset, :player2_id)

    cond do
      player_1_wins > player_2_wins ->
        changeset
        |> put_change(:winner_id, player1_id)
        |> put_change(:is_draw, false)

      player_2_wins > player_1_wins ->
        changeset
        |> put_change(:winner_id, player2_id)
        |> put_change(:is_draw, false)

      player_1_wins == player_2_wins ->
        changeset
        |> put_change(:winner_id, nil)
        |> put_change(:is_draw, true)

      true ->
        changeset
    end
  end

  @doc false
  def changeset(match, attrs) do
    match

    |> cast(attrs, all_fields())
    #|> calculate_winner()
    |> validate_required(all_fields() -- @optional_fields)

  end
end
