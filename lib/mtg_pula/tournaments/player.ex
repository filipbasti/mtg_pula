defmodule MtgPula.Tournaments.Player do
  use Ecto.Schema
  import Ecto.Changeset


  @optional_fields [:id, :inserted_at, :updated_at, :points, :had_bye, :dropped]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :deck, :string
    field :opponents, {:array, Ecto.UUID}, default: []
    field :points, :integer
    field :had_bye, :boolean
    field :dropped, :boolean
    belongs_to :tournament, MtgPula.Tournaments.Tournament
    belongs_to :user, MtgPula.Users.User
    has_many :matches_as_player1, MtgPula.Tournaments.Match, foreign_key: :player1_id
    has_many :matches_as_player2, MtgPula.Tournaments.Match, foreign_key: :player2_id
    has_many :matches_as_winner, MtgPula.Tournaments.Match, foreign_key: :winner_id
    timestamps(type: :utc_datetime)
  end
  defp all_fields do
    __MODULE__.__schema__(:fields)
  end
  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :players_user_id_fkey)
    |> unique_constraint([:tournament_id, :user_id], name: :unique_tournament_player)
  end
end
