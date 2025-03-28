defmodule MtgPula.Users.User do
  @moduledoc """
  Represents a user schema.

  This schema is used to store user-related information, such as their full name, gender, and biography.

  ## Fields

  - `id` (binary_id): The unique identifier for the user (autogenerated).
  - `full_name` (string): The full name of the user.
  - `gender` (string): The gender of the user.
  - `biography` (string): A short biography or description of the user.
  - `inserted_at` (utc_datetime): The timestamp when the user was created.
  - `updated_at` (utc_datetime): The timestamp when the user was last updated.

  ## Relationships

  - `belongs_to :account`: Each user is associated with an account. See [`Account Schema`](MtgPula.Accounts.Account.html).
  - `has_many :player`: A user can participate as a player in multiple tournaments. See [`Player Schema`](MtgPula.Tournaments.Player.html).
  - `has_many :tournament`: A user can organize multiple tournaments. See [`Tournament Schema`](MtgPula.Tournaments.Tournament.html).

  ## Examples

      # Creating a new user
      attrs = %{full_name: "John Doe", gender: "Male", biography: "A passionate player"}
      changeset = MtgPula.Users.User.changeset(%MtgPula.Users.User{}, attrs)

      if changeset.valid? do
        Repo.insert(changeset)
      else
        IO.inspect(changeset.errors)
      end
  """
  use Ecto.Schema
  import Ecto.Changeset

  @optional_fields [:id, :biography, :full_name, :gender, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :full_name, :string
    field :gender, :string
    field :biography, :string

    belongs_to :account, MtgPula.Accounts.Account
    has_many :player, MtgPula.Tournaments.Player
    has_many :tournament, MtgPula.Tournaments.Tournament

    timestamps(type: :utc_datetime)
  end


  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc """
  Creates a changeset for a user.

  ## Parameters

  - `user` (struct): The user struct to update.
  - `attrs` (map): A map of attributes to apply to the changeset.

  ## Validations

  - `full_name`: Must be present.
  - `gender`: Must be present.
  - `biography`: Optional.

  ## Examples

      iex> changeset(%MtgPula.Users.User{}, %{full_name: "John Doe", gender: "Male"})
      %Ecto.Changeset{...}

      iex> changeset(%MtgPula.Users.User{}, %{full_name: nil})
      %Ecto.Changeset{valid?: false, errors: [full_name: {"can't be blank", []}]}
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
  end
end
