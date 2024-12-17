defmodule MtgPulaWeb.RoomChannelTest do
  use MtgPulaWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      MtgPulaWeb.UserSocket
      |> socket("account_id", %{account_id: "1234"})
      |> subscribe_and_join(MtgPulaWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "joins lobby successfully" do
    {:ok, _, socket} =
      MtgPulaWeb.UserSocket
      |> socket("account_id", %{account_id: "1234"})
      |> subscribe_and_join(MtgPulaWeb.RoomChannel, "room:lobby")

    assert socket.joined
    assert socket.topic == "room:lobby"
  end
end
