defmodule MtgPulaWeb.TournamentChannelTest do
  use MtgPulaWeb.ChannelCase

  alias MtgPula.Tournaments
  alias MtgPula.Support.Factory

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)
    tourney = Factory.insert(:tournament)

    {:ok, _, socket} =
      MtgPulaWeb.UserSocket
      |> socket("account_id", %{account_id: tourney.user.account.id})
      |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")

    %{account: tourney.user.account, socket: socket, tourney: tourney}
  end

  describe "join/3" do
    test "joins tournament channel successfully", %{account: account, tourney: tourney} do
      assert {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")
      assert socket.topic == "tournament:#{tourney.join_code}"
      assert socket.assigns.account_id == account.id
    end
  end
  describe "handle_in for drop_player"do
    setup %{socket: socket} do
      user = Factory.insert(:user)
      params = %{"user_id" => user.id, "deck" => "Deck 1", dropped: false, had_bye: false}
      ref = push(socket, "add_player", params)
      assert_reply ref, :ok, params
      added_player = params.player
      %{added_player: added_player}
    end

    test "drop player successfully", %{socket: socket, added_player: added_player} do
      ref = push(socket, "drop_player", %{player_id: added_player.id})
      assert_reply ref, :ok, _added_player
      assert_broadcast "player_dropped", _added_player
    end

    test "non-organizer player tries to drop a player", %{tourney: tourney, added_player: added_player} do
      user = Factory.insert(:user)

      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")

      params = %{"player_id" => added_player.id}
      ref = push(socket, "drop_player", params)
      assert_reply ref, :error, %{reason: "You are not authorized to drop players"}
    end
  end
  describe "handle_in/3 for add_player" do
    test "add_player successfully", %{socket: socket} do
      user = Factory.insert(:user)
      params = %{"user_id" => user.id, "deck" => "Deck 1"}
      ref = push(socket, "add_player", params)
      assert_reply ref, :ok, params
      _broadcasted = params["player"]
      assert_broadcast "player_added", _broadcasted
    end

    test "add_player fails", %{socket: socket} do
      params = %{"user_id" => "", "deck" => ""}
      ref = push(socket, "add_player", params)
      assert_reply ref, :error, _params
    end

    test "non-organizer player tries to add", %{tourney: tourney} do
      user = Factory.insert(:user)

      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")

      params = %{"user_id" => "", "deck" => ""}
      ref = push(socket, "add_player", params)
      assert_reply ref, :error, %{reason: "You are not authorized to add players"}
    end
  end

  describe "handle_in/3 for remove_player" do
    setup %{socket: socket} do
      user = Factory.insert(:user)
      params = %{"user_id" => user.id, "deck" => "Deck 1"}
      ref = push(socket, "add_player", params)
      assert_reply ref, :ok, params
      added_player = params.player
      %{added_player: added_player}
    end

    test "remove player successfully", %{socket: socket, added_player: added_player} do
      ref = push(socket, "remove_player", %{player_id: added_player.id})
      assert_reply ref, :ok, _added_player
      assert_broadcast "player_removed", _added_player
    end

    test "non-organizer player tries to remove a player", %{tourney: tourney} do
      user = Factory.insert(:user)

      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")

      params = %{"user_id" => "", "deck" => ""}
      ref = push(socket, "remove_player", params)
      assert_reply ref, :error, %{reason: "You are not authorized to remove players"}
    end
  end

  describe "handle_in/3 for get_players" do
    test "get all players in the tournament", %{socket: socket} do
      user = Factory.insert(:user)
      params = %{"user_id" => user.id, "deck" => "Deck 1", dropped: false, had_bye: false}
      ref = push(socket, "add_player", params)
      assert_reply ref, :ok, added_player

      ref = push(socket, "get_players", %{})
      assert_reply ref, :ok, %{players: [first_player | _]}
      assert added_player.player == first_player
    end

    test "returns an empty array if no players are added", %{socket: socket} do
      ref = push(socket, "get_players", %{})
      assert_reply ref, :ok, %{players: []}
    end
  end

  describe "handle_in/3 for prepare_matches" do
    setup %{tourney: tourney} do
      players = Factory.insert_list(9, :player, [tournament: tourney, opponents: [], points: 0, had_bye: false, dropped: false])
      %{players: players}
    end

    test "prepare matches for the tournament", %{socket: socket} do
      ref = push(socket, "prepare_matches", %{})
      assert_reply ref, :ok, %{matches: matches}
      assert is_list(matches), "Expected matches to be a list"
      assert length(matches) == 5, "Expected 5 matches to be prepared"
    end

    test "non-organizer player tries to prepare matches", %{tourney: tourney} do
      user = Factory.insert(:user)

      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")
      ref = push(socket, "prepare_matches", %{})
      assert_reply ref, :error, %{reason: "You are not authorized to prepare matches"}
    end

    test "tournament is finished", %{socket: socket, tourney: tourney} do
      updated_tourney = Tournaments.update_tournament(tourney, %{current_round: tourney.number_of_rounds, finished: true})

      assert updated_tourney != tourney
      ref = push(socket, "prepare_matches", %{})
      assert_reply ref, :error, %{reason: "finished", redirect: true}
    end
  end

  describe "handle_in/3 for update_match" do
    setup %{tourney: tourney, socket: socket} do
      players = Factory.insert_list(9, :player, [tournament: tourney, opponents: [], points: 0, had_bye: false, dropped: false])
      player = List.first(players)
      push(socket, "prepare_matches", %{})
      ref = push(socket, "current_matches", %{})
      assert_reply ref, :ok, matches
      match = List.first(matches.matches)
      %{match: match, player: player, matches: matches.matches}
    end

    test "update match successfully", %{socket: socket, match: match} do
      push(socket, "update_match", %{id: match.id, player_1_wins: 2, player_2_wins: 1, on_play_id: match.player1.id})
      assert_broadcast "match_updated", %{message: "updated match", id: _match_id}
    end

    test "failed to update match because of wrong params", %{socket: socket, match: match} do
      ref = push(socket, "update_match", %{id: match.id, player_1_wins: "aaa", player_2_wins: 1, on_play_id: match.player1.id})
      assert_reply ref, :error, %{reason: reason}
      assert reason.valid? == false, "Expected the reason to be invalid"
    end

    test "player in match is able to update match", %{player: player, tourney: tourney, matches: matches} do
      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: player.user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")
      match_id = Enum.find_value(matches, fn match ->
        if match.player1.id == player.id or match.player2.id == player.id do
          match.id
        else
          nil
        end
      end)
      push(socket, "update_match", %{id: match_id, player_1_wins: 2, player_2_wins: 1, on_play_id: player.id})
      assert_broadcast "match_updated", %{message: "updated match", id: match_id_broadcasted}
      assert match_id_broadcasted == match_id, "Expected the match id to be the same"
    end

    test "non-organizer player tries to update a match", %{tourney: tourney, match: match} do
      user = Factory.insert(:user)

      {:ok, _, socket} =
        MtgPulaWeb.UserSocket
        |> socket("account_id", %{account_id: user.account.id})
        |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:#{tourney.join_code}")
      ref = push(socket, "update_match", %{id: match.id, player_1_wins: 2, player_2_wins: 1, on_play_id: match.player1.id})
      assert_reply ref, :error, %{reason: "You are not authorized to update"}
    end
  end

  describe "handle_in/3 for get_user_by_email" do
    test "get user by email successfully", %{socket: socket} do
      user = Factory.insert(:user)
      ref = push(socket, "get_user_by_email", %{"email" => user.account.email})
      assert_reply ref, :ok, user
    end

    test "get user by email fails", %{socket: socket} do
      ref = push(socket, "get_user_by_email", %{"email" => "nonexistent@example.com"})
      assert_reply ref, :error, %{reason: "User not found"}
    end
  end

  describe "handle_in/3 for get_standings" do
    test "get standings successfully", %{socket: socket, tourney: tourney} do
      players = Factory.insert_list(9, :player, [tournament: tourney, opponents: [], points: 0, had_bye: false, dropped: false])
      push(socket, "prepare_matches", %{})
      ref = push(socket, "get_standings", %{})
      assert_reply ref, :ok, standings

    end
  end
end
