defmodule MtgPulaWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", MtgPulaWeb.RoomChannel

  def connect(_params, socket, _connect_info) do
    IO.inspect(socket)
    {:ok, socket}
  end

  def id(_socket), do: "socket"
end
