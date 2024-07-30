defmodule MtgPula.Support.TournamentCase do
  use ExUnit.CaseTemplate
  alias MtgPula.{Tournaments,Users,Accounts}
  using do
    quote do
      alias Ecto.Changeset
      import MtgPula.Support.TournamentCase
    end
  end

setup do
  Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
  {:ok, account} = Accounts.create_acccount(%{email: Faker.Internet.email(), hash_password: Faker.Lorem.word()})
  {:ok, user} = Users.create_user(account, %{biography: Faker.Lorem.sentence(), full_name: Faker.Name.name(), gender: Enum.random(["male", "female"])})
  {:ok, tournament} = Tournaments.create_tournament(%{
    name: Faker.Lorem.word(),
    finished: Enum.random([true, false]),
    current_round: Enum.random(1..10),
    number_of_rounds: Enum.random(1..10),
    user_id: user.id
  })

  {:ok, user: user, tournament: tournament}
end


end
