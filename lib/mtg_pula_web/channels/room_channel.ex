defmodule MtgPulaWeb.RoomChannel do
  alias MtgPula.Accounts
  use Phoenix.Channel
  alias MtgPulaWeb.Presence

  @doc """
  Joins the lobby room.

  """
  def join("room:lobby", _message, socket) do
    send(self(), :after_join) # TODO: check if user is in the lobby and add them to the lobby list
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
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.account_id, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
