defmodule MtgPulaWeb.Auth.AuthorizedPlug do
  alias MtgPulaWeb.Auth.ErrorResponse
  alias MtgPula.Tournaments
  def is_authorized(%{params: %{"account" => params}} = conn, _opts) do
    if conn.assigns.account.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"user" => params}} = conn, _opts) do
    if conn.assigns.account.user.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"tournament_id" => tournament_id}} = conn, _opts) do
    tournament= Tournaments.get_tournament!(tournament_id)
    if conn.assigns.account.user.id == tournament.user_id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"tournament" => params}} = conn, _opts) do

    if conn.assigns.account.user.id == params["user_id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"player" => player}} = conn, _opts) do

    tournament= Tournaments.get_tournament!(player["tournament_id"])
    if conn.assigns.account.user.id == tournament.user_id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  # def is_authorized(%{params: %{"match" => match}} = conn, _opts) do
  #   IO.inspect(match)
  #   tournament= Tournaments.get_tournament!(match["tournament_id"])
  #   if conn.assigns.account.user.id == tournament.user_id do
  #     conn
  #   else
  #     raise ErrorResponse.Forbidden
  #   end
  # end
end
