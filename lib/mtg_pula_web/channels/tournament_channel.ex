defmodule MtgPulaWeb.TournamentChannel do
  use Phoenix.Channel
  alias MtgPula.Tournaments
  alias MtgPulaWeb.Presence
  alias MtgPula.Accounts

  def join("tournament:" <> tournament_id, _params, socket) do
    account_id = socket.assigns.account_id
    send(self(), :after_join)
    case Tournaments.get_tournament!(tournament_id) do
      nil ->
        {:error, %{reason: "Tournament not found"}}
      tournament ->
        if tournament.user_id == account_id do
          socket = assign(socket, :tournament_id, tournament.id)
          socket = assign(socket, :role, "organizer")
          {:ok, socket}
        else
          {:ok, socket}
        end
    end
  end
  def handle_info(:after_join, socket) do
    full_account = Accounts.get_full_account(socket.assigns.account_id)
    {:ok, _} =
      Presence.track(socket, full_account.user.id, %{
        entered_at: inspect(System.system_time(:second))
      })
    {:noreply, socket}
  end
  def handle_in("add_player", params, socket) do
    tournament_id = socket.assigns.tournament_id
    params = Map.put(params, "tournament_id", tournament_id)
   case  Tournaments.create_player(params) do

    {:ok, player} ->
      broadcast!(socket, "player_added", %{player: player})
      {:noreply, socket}
    {:error, _changeset} ->
      {:reply, {:error, %{reason: "Failed to add player"}}, socket}
   end

    {:noreply, socket}
  end
  def handle_in("remove_player", params, socket) do
    case Tournaments.delete_player(params["player_id"]) do
      {:ok, player} ->
        broadcast!(socket, "player_removed", %{player: player})
        {:noreply, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Failed to remove player"}}, socket}
    end
  end
  def handle_in("update_player", params, socket) do
    case Tournaments.update_player(params["player_id"], params) do
      {:ok, player} ->
        broadcast!(socket, "player_updated", %{player: player})
        {:noreply, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Failed to update player"}}, socket}
    end
  end

  def handle_in("list_present_users", _params, socket) do
    players = Presence.list(socket)
    {:reply, {:ok, %{players: players}}, socket}
  end
  def join(_topic, _params, _socket) do
    IO.puts("Unmatched topic")
    {:error, %{reason: "unmatched topic"}}
  end
end
