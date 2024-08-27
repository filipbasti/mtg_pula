defmodule MtgPula.Support.Factory do
  use ExMachina.Ecto, repo: MtgPula.Repo
  alias MtgPula.Accounts.Account
  alias MtgPula.Users.User
  alias MtgPula.Tournaments.{Tournament, Player, Match}



  def account_factory do
    %Account{
      email: Faker.Internet.email(),
      hash_password: Faker.Internet.slug()
    }


  end


  def user_factory do
    %User{
      full_name: Faker.Person.name(),
      gender: Enum.random(["male", "female"]),
      biography: Faker.Lorem.paragraph(2..5),
      account: build(:account)
    }

  end



  def tournament_factory do
    %Tournament{
    name: Faker.Lorem.word(),
    finished: Enum.random([true, false]),
    current_round: Enum.random(1..10),
    number_of_rounds: Enum.random(1..10),
    user: build(:user)
  }
  |>set_current_round()

  end
  defp set_current_round(tournament) do
    %{tournament | current_round: 1}
  end
  def player_factory do
    %Player{
    deck: Faker.Lorem.word(),
    opponents: Enum.map(1..3, fn _ -> Faker.UUID.v4() end),
    points: Faker.random_between(1, 10),
    had_bye: Enum.random([true, false]),
    tournament: build(:tournament),
    user: build(:user),
    dropped: false

    }
  end


  def match_factory do

    player1 = insert(:player)
    player2 = insert(:player)

    %Match{

        round: Faker.random_between(1, 5),
     player_1_wins: nil,
       player_2_wins: nil,
     is_draw: nil,

        player1: player1,
        player2: player2,
        on_play_id: nil,
        winner_id: nil,

        tournament: player1.tournament
    }

    |> set_wins()
    |> set_winner()
    |>set_on_play()




  end

  defp set_wins(%Match{} = match) do
    total_wins = Faker.random_between(1, 3)
    player_1_wins = Faker.random_between(0, total_wins-1)
    player_2_wins = total_wins - player_1_wins

    %{match | player_1_wins: player_1_wins, player_2_wins: player_2_wins}
  end
  defp set_winner(%Match{player_1_wins: p1_wins, player_2_wins: p2_wins, player1: p1, player2: p2} = match) do
    cond do
      p1_wins > p2_wins ->

        %{match | winner: p1}
      p2_wins > p1_wins ->

        %{match | winner: p2}
      p1_wins == p2_wins ->

        %{match | winner: nil, is_draw: true}
    end
  end

  defp set_on_play(%Match{player1: p1_id, player2: p2_id} = match) do
    play_id = Enum.random([p1_id, p2_id])

    %{match | on_play: play_id}
  end




end
