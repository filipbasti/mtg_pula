defmodule MtgPula.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :deck, :string
      add :opponents, {:array, :uuid}
      add :points, :integer
      add :dropped, :boolean, default: false, null: false
      add :had_bye, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :tournament_id, references(:tournaments, on_delete: :delete_all, type: :binary_id)
      timestamps(type: :utc_datetime)
    end

    create index(:players, [:user_id])
    create index(:players, [:tournament_id])
  end
end
