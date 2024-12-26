defmodule MtgPulaWeb.TournamentChannel do
  use Phoenix.Channel
  alias MtgPula.Tournaments
  alias MtgPulaWeb.Presence
  alias MtgPula.Accounts

  #Joins the tournament channel by join code.

  def join("tournament:" <> join_code, _params, socket) do
    account_id = socket.assigns.account_id
    send(self(), :after_join)
    case Tournaments.get_tournament_by_join_code(join_code)  do
      nil ->
        {:error, %{reason: "Tournament not found"}}
      tournament ->
        if tournament.user_id == account_id do
          socket = assign(socket, :tournament_id, tournament.id)
          socket = assign(socket, :role, "organizer")
          {:ok, socket}
        else
          socket = assign(socket, :tournament_id, tournament.id)
          {:ok, socket}
        end
    end
  end
#Handles unmatched topics.

def join(_topic, _params, _socket) do
  IO.puts("Unmatched topic")
  {:error, %{reason: "unmatched topic"}}
end

  #Handles the after join event. Tracks the user presence.

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

  #Adds a player to the tournament.

  def handle_in("add_player", params, socket) do
    tournament_id = socket.assigns.tournament_id
    params = Map.put(params, "tournament_id", tournament_id)

   case  Tournaments.create_player(params) do

    {:ok, player} ->
      IO.inspect("uspjeh")
      broadcast!(socket, "player_added", %{player: player})
      {:reply, socket}
    {:error, changeset} ->
      IO.inspect("failed")
      {:reply, {:error, %{reason: "player already exist or there is an internal error"}}, socket}
   end

  end


  #Removes a player from the tournament.

  def handle_in("remove_player", params, socket) do
    case Tournaments.delete_player(params["player_id"]) do
      {:ok, player} ->
        broadcast!(socket, "player_removed", %{player: player})
        {:noreply, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Failed to remove player"}}, socket}
    end
  end


  #Updates a player in the tournament.

  def handle_in("update_player", params, socket) do
    case Tournaments.update_player(params["player_id"], params) do
      {:ok, player} ->
        broadcast!(socket, "player_updated", %{player: player})
        {:noreply, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Failed to update player"}}, socket}
    end
  end


  #Lists the present users in the tournament.

  def handle_in("list_present_users", _params, socket) do
    players = Presence.list(socket)
    {:reply, {:ok, %{players: players}}, socket}
  end




 #Prepares the matches for the tournament.

  def handle_in("prepare_matches", _params, socket) do
    if socket.assigns.role == "organizer" do
      case Tournaments.prepare_matches(socket.assigns.tournament_id) do
        {:ok, _matches} ->
          {:noreply, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  else
    {:reply, {:error, %{reason: "You are not authorized to prepare matches"}}, socket}
  end
  end

  #Gets the current matches for the tournament.

  def handle_in("current_matches", _params, socket) do
    case Tournaments.current_matches(socket.assigns.tournament_id) do
      {:ok, matches} ->
        {:reply, {:ok, %{matches: matches}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
