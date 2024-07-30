defmodule MtgPula.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  @optional_fields [:id, :inserted_at, :updated_at, :current_round]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tournaments" do
    field :name, :string
    field :finished, :boolean
    field :current_round, :integer
    field :number_of_rounds, :integer
    has_many :match, MtgPula.Tournaments.Match
    has_many :player, MtgPula.Tournaments.Player

    timestamps(type: :utc_datetime)

    belongs_to :user, MtgPula.Users.User
  end
  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> assoc_constraint(:user)
  end



end
