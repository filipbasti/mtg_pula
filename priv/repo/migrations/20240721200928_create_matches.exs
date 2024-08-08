defmodule MtgPula.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :round, :integer
      add :player_1_wins, :integer
      add :player_2_wins, :integer
      add :player1_id, references(:players, on_delete: :nothing, type: :binary_id)
      add :player2_id, references(:players, on_delete: :nothing, type: :binary_id)
      add :winner_id, references(:players, on_delete: :nothing, type: :binary_id)
      add :tournament_id, references(:tournaments, on_delete: :nothing, type: :binary_id)
      add :is_draw, :boolean # New field
      add :on_play_id, references(:players, on_delete: :nothing, type: :binary_id)
      timestamps(type: :utc_datetime)
    end

    create index(:matches, [:player1_id])
    create index(:matches, [:player2_id])
    create index(:matches, [:winner_id])
    create index(:matches, [:tournament_id])
  end
end
