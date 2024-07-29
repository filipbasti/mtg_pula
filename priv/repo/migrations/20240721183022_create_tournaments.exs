defmodule MtgPula.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :current_round, :integer
      add :number_of_rounds, :integer
      add :finished, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      timestamps(type: :utc_datetime)
    end
  end
end
