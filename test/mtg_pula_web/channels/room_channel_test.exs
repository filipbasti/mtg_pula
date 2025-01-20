defmodule MtgPulaWeb.RoomChannelTest do
  use MtgPulaWeb.ChannelCase

  alias MtgPula.Accounts
  alias MtgPula.Accounts.Account
  alias MtgPula.Users
  alias MtgPula.Support.Factory

  setup do
    params = Factory.string_params_for(:account)

    {:ok, %Account{} = account} = Accounts.create_account(params)
    params = %{"full_name" => "test"}
    Users.create_user(account, params)
    {:ok, _, socket} =
      MtgPulaWeb.UserSocket
          |> socket("account_id", %{account_id: account.id})
          |> subscribe_and_join(MtgPulaWeb.RoomChannel, "room:lobby")

    %{account: account, socket: socket, params: params}
  end

  test "joins lobby successfully", %{account: account} do
    assert {:ok, _, socket} =
      MtgPulaWeb.UserSocket
          |> socket("account_id", %{account_id: account.id})
          |> subscribe_and_join(MtgPulaWeb.RoomChannel, "room:lobby")
    assert socket.topic == "room:lobby"
    assert socket.assigns.account_id == account.id
  end
  test "new_msg broadcast to room:lobby", %{socket: socket} do
    push(socket, "new_msg", %{"body" => "all"})
    assert_broadcast "new_msg", %{"body" => "all"}
  end
end
