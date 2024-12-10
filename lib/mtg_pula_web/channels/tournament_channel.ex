
defmodule MtgPulaWeb.TournamentChannel do
  use Phoenix.Channel
  alias MtgPula.Tournaments


  def join("tournament:" <> tournament_id, _params, socket) do
    account_id = socket.assigns.account_id

    case Tournaments.get_tournament!(tournament_id) do
      nil ->
        {:error, %{reason: "Tournament not found"}}
      tournament ->
        if tournament.organizer_id == account_id do
          socket = assign(socket, :tournament_id, tournament.id)
          socket = assign(socket, :role, "organizer")
          {:ok, socket}
        else
          {:ok, socket}
        end
    end
  end



  def join("tournament:" <> _tournament_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
