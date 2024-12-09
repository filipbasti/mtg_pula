defmodule MtgPulaWeb.RoomChannel do
  alias MtgPula.Accounts
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket} # TODO: check if user is in the lobby and add them to the lobby list
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}} # TODO: check if user is in the room
  end
  def handle_in("new_msg", %{"body" => body}, socket) do
    account_id = socket.assigns.account_id
    IO.inspect(account_id)
    user = Accounts.get_full_account(account_id)

    broadcast!(socket, "new_msg", %{body: body, sender: user.email})
    {:noreply, socket}
  end
end
