defmodule MtgPulaWeb.TournamentChannel do
  use Phoenix.Channel
  alias MtgPula.Repo
  alias MtgPula.Tournaments
  alias MtgPulaWeb.Presence
  alias MtgPula.Accounts

  alias MtgPulaWeb.TournamentChannelJSON


  #translates the errors in the changeset.
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, messages} ->
      "#{field}: #{Enum.join(messages, ", ")}"
    end)
    |> Enum.join("; ")
  end


  #Checks if the user is authorized to update the match.
  defp authorized_to_update_match?(socket, match) do
    socket.assigns.role == "organizer" or
      match.player1.user_id == socket.assigns.user.user.id or
      match.player2.user_id == socket.assigns.user.user.id
  end

  #Joins the tournament channel by join code.

  def join("tournament:" <> join_code, params, socket) do
    account_id = socket.assigns.account_id
    user = Accounts.get_full_account(account_id)

    send(self(), :after_join)
    case Tournaments.get_tournament_by_join_code(join_code) do
      nil ->
        {:error, %{reason: "Tournament not found"}}
      tournament ->
        deck = Map.get(params, "deck", nil)  # Get the deck from params or default to nil
        if tournament.user_id == user.user.id do

          socket = assign(socket, :tournament_id, tournament.id)
          socket = assign(socket, :role, "organizer")
          socket = assign(socket, :deck, deck)  # Assign the deck to the socket
          {:ok, socket}
        else

          socket = assign(socket, :tournament_id, tournament.id)
          socket = assign(socket, :deck, deck)  # Assign the deck to the socket
          socket = assign(socket, :role, "player")

          {:ok, socket}
        end
    end
  end
#Handles unmatched topics.

def join(_topic, _params, _socket) do

  {:error, %{reason: "unmatched topic"}}
end

  #Handles the after join event. Tracks the user presence.

  def handle_info(:after_join, socket) do
    account_id = socket.assigns.account_id
    user = Accounts.get_full_account(account_id)
    socket = assign(socket, :user, user)
    {:ok, _} =
      Presence.track(socket, user.user.id, %{
        online_at: inspect(System.system_time(:second)),
        user_name: user.user.full_name,
        deck: socket.assigns.deck
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end



    def handle_in("get_user_by_email", %{"email" => email}, socket) do
    case Accounts.get_account_by_email(email) do
      nil ->
        {:reply, {:error, %{reason: "User not found"}}, socket}
      account ->
        {:reply, {:ok, %{user_id: account.user.id}}, socket}
    end
    end



  #Adds a player to the tournament.

  def handle_in("add_player", params, socket) do
    if socket.assigns.role == "organizer" do
      tournament_id = socket.assigns.tournament_id
      params = Map.put(params, "tournament_id", tournament_id)

      case Tournaments.create_player(params) do
        {:ok, player} ->
          player = Repo.preload(player, :user)
          player_json = TournamentChannelJSON.render("player.json", player)
          broadcast!(socket, "player_added", %{player: player_json})
          {:reply, {:ok, %{player: player_json}}, socket}
        {:error, changeset} ->
          {:reply, {:error, %{reason: "player already exist or there is an internal error", changeset_errors: translate_errors(changeset)}}, socket}
      end
    else
      {:reply, {:error, %{reason: "You are not authorized to add players"}}, socket}
    end
  end

  #Gets the players in the tournament.
  def handle_in("get_players", _params, socket) do
    tournament_id = socket.assigns.tournament_id

   case  Tournaments.list_all_tournament_players(tournament_id) do

    {:ok, players} ->

      players_json = TournamentChannelJSON.render("players_start.json", players)
        {:reply, {:ok, %{players: players_json}}, socket}
    {:error, :not_found} ->

      {:reply, {:error, %{reason: "There is nothing found here"}}, socket}
   end

  end

  #Removes a player from the tournament.
  def handle_in("remove_player", params, socket) do
    if socket.assigns.role == "organizer" do
      case Tournaments.delete_player(params["player_id"]) do
        {:ok, player} ->
          player_json = TournamentChannelJSON.render("player.json", player)
          broadcast!(socket, "player_removed", %{player: player_json})
          {:reply, {:ok, %{player: player_json}}, socket}
        {:error, _changeset} ->
          {:reply, {:error, %{reason: "Failed to remove player"}}, socket}
      end
    else
      {:reply, {:error, %{reason: "You are not authorized to remove players"}}, socket}
    end
  end


  #Updates a player in the tournament.

  def handle_in("update_player", params, socket) do
    if socket.assigns.role == "organizer" do
      case Tournaments.update_player(params["player_id"], params) do
        {:ok, player} ->
          broadcast!(socket, "player_updated", %{player: player})
          {:noreply, socket}
        {:error, _changeset} ->
          {:reply, {:error, %{reason: "Failed to update player"}}, socket}
      end
    else
      {:reply, {:error, %{reason: "You are not authorized to update players"}}, socket}
    end
  end


 #Prepares the matches for the tournament.

 def handle_in("prepare_matches", _params, socket) do


  if socket.assigns.role == "organizer" do
    case Tournaments.prepare_matches(socket.assigns.tournament_id) do
      {:ok, _tournament, matches} ->
        matches_json = TournamentChannelJSON.render("matches.json", matches)
        broadcast!(socket, "matches_prepared", %{matches: matches_json})
        {:reply, {:ok, %{matches: matches_json}}, socket}
      {:error, :finished_tourney} ->

        {:reply, {:error, %{reason: "finished", redirect: true}}, socket}
    end
  else
    {:reply, {:error, %{reason: "You are not authorized to prepare matches"}}, socket}
  end
end

  def handle_in("update_match", params, socket) do
     match =
      Tournaments.get_match!(params["id"])
      |> Repo.preload(:player1)
      |> Repo.preload(:player2)


     if authorized_to_update_match?(socket, match) do
      case Tournaments.update_match(match, %{player_1_wins: params["player_1_wins"], player_2_wins: params["player_2_wins"], on_play_id:  params["on_play_id"] }) do
        {:ok, match} ->
          broadcast!(socket, "match_updated", %{message: "updated match", id: match.id})
          {:noreply, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}

  end
    else
      {:reply, {:error, %{reason: "You are not authorized to update"}}, socket}
end
  end
  #Gets the current matches for the tournament.

  def handle_in("current_matches", _params, socket) do
    case Tournaments.current_matches(socket.assigns.tournament_id) do
      {:ok, matches} ->
        matches_json = TournamentChannelJSON.render("matches.json", matches)
        {:reply, {:ok, %{matches: matches_json}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end


  def handle_in("get_standings", params, socket) do
    tournament =
      case params do
        %{"join_code" => join_code} ->
          Tournaments.get_tournament_by_join_code(join_code)
        _ ->
          Tournaments.get_tournament!(socket.assigns.tournament_id)
      end

    case tournament do
      nil ->
        {:reply, {:error, %{reason: "Tournament not found"}}, socket}
      tournament ->
        case Tournaments.standings_on_tournament(tournament.id) do
          {:ok, players} ->
            players_json = TournamentChannelJSON.render("standings.json", players)
            {:reply, {:ok, %{players: players_json}}, socket}
          {:error, :not_found} ->
            {:reply, {:error, %{reason: "Standings not found"}}, socket}
        end
    end
  end
end
