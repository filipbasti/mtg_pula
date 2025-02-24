defmodule MtgPulaWeb.UserSocket do
  use Phoenix.Socket
  alias MtgPulaWeb.Auth.Guardian

  channel "room:*", MtgPulaWeb.RoomChannel
  channel "tournament:*", MtgPulaWeb.TournamentChannel
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, account} <- Guardian.resource_from_claims(claims) do
      {:ok, assign(socket, :account_id, account.id)}
    else
      _ -> {:error, %{reason: "Unauthorized"}}
    end
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

 def id(socket), do: "user_socket:"
end
