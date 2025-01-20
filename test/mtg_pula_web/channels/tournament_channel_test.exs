defmodule MtgPulaWeb.TournamentChannelTest do
  use MtgPulaWeb.ChannelCase

  alias MtgPula.Accounts
  alias MtgPula.Accounts.Account
  alias MtgPula.Tournaments
  alias MtgPula.Support.Factory

  setup do
    params = Factory.string_params_for(:account)
    {:ok, %Account{} = account} = Accounts.create_account(params)
    {:ok, _, socket} =
      MtgPulaWeb.UserSocket
      |> socket("account_id", %{account_id: account.id})
      |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:1234")

    %{account: account, socket: socket}
  end
@tag :skip
  test "joins tournament channel successfully", %{account: account} do
    assert {:ok, _, socket} =
      MtgPulaWeb.UserSocket
      |> socket("account_id", %{account_id: account.id})
      |> subscribe_and_join(MtgPulaWeb.TournamentChannel, "tournament:1234")
    assert socket.topic == "tournament:1234"
    assert socket.assigns.account_id == account.id
  end
  @tag :skip
  test "add_player broadcasts player_added", %{socket: socket} do
    push(socket, "add_player", %{"name" => "Player 1"})
    assert_broadcast "player_added", %{"player" => %{"name" => "Player 1"}}
  end


end
