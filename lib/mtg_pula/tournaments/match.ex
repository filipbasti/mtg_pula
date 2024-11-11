defmodule MtgPula.Tournaments.Match do
  use Ecto.Schema
  import Ecto.Changeset
  @optional_fields [:id, :inserted_at, :updated_at, :is_draw, :player_1_wins, :player_2_wins, :on_play, :winner_id, :player2_id]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    field :round, :integer
    field :player_1_wins, :integer
    field :player_2_wins, :integer
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
  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, all_fields())
    |> validate_required(all_fields()-- @optional_fields)
  end
end
