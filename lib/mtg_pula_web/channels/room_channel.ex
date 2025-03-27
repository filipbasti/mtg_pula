defmodule MtgPulaWeb.RoomChannel do
  alias MtgPula.Accounts
  use Phoenix.Channel
  alias MtgPulaWeb.Presence

  @doc """
  Joins the lobby room.

  """
  def join("room:lobby", _message, socket) do
    # TODO: check if user is in the lobby and add them to the lobby list
    send(self(), :after_join)
    # TODO: check if user is in the lobby and add them to the lobby list
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    # TODO: check if user is in the room
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", payload, socket) do
    broadcast!(socket, "new_msg", payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    account_id = socket.assigns.account_id
    user = Accounts.get_full_account(account_id)
    socket = assign(socket, :user, user)

    {:ok, _} =
      Presence.track(socket, user.id, %{
        online_at: inspect(System.system_time(:second)),
        user_name: user.user.full_name
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
