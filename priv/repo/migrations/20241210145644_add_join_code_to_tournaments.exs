defmodule MtgPula.Repo.Migrations.AddJoinCodeToTournaments do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add :join_code, :string
    end

    create unique_index(:tournaments, [:join_code])
  end
end
