defmodule MtgPula.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  @optional_fields [:id, :inserted_at, :updated_at, :current_round, :join_code]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tournaments" do
    field :name, :string
    field :finished, :boolean
    field :current_round, :integer
    field :number_of_rounds, :integer
    field :join_code, :string
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
    |> put_join_code()
    |> unique_constraint(:join_code)
    |> assoc_constraint(:user)
  end

  defp put_join_code(changeset) do
    if get_field(changeset, :join_code) do
      changeset
    else
      changeset
      |> put_change(:join_code, generate_unique_code())
    end
  end

  defp generate_unique_code do
    # Logic to generate a unique code
    # For example, a random string of 8 alphanumeric characters
    :crypto.strong_rand_bytes(4)
    |> Base.encode16()
    |> binary_part(0, 6)
  end

end
