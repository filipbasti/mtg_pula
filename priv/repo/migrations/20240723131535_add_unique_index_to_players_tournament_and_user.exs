defmodule MtgPula.Repo.Migrations.AddUniqueIndexToPlayersTournamentAndUser do
  use Ecto.Migration

  def change do
    create unique_index(:players, [:tournament_id, :user_id], name: :unique_tournament_player)
  end
end
