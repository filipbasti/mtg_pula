defmodule MtgPulaWeb.Auth.SetAccount do
  import Plug.Conn
  alias MtgPulaWeb.Auth.ErrorResponse
  alias MtgPula.Accounts
  require Logger

  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:account] do
      Logger.debug("Account already assigned: #{inspect(conn.assigns[:account])}")
      conn
    else
      account_id = get_session(conn, :account_id)
      Logger.debug("Account ID from session: #{inspect(account_id)}")
      if account_id == nil do
        Logger.debug("Account ID is nil, raising Unauthorized error")
        raise ErrorResponse.Unauthorized
      end
      account = Accounts.get_full_account(account_id)
      Logger.debug("Fetched account: #{inspect(account)}")
      cond do
        account_id && account ->
          Logger.debug("Assigning account to conn: #{inspect(account)}")
          assign(conn, :account, account)
        true ->
          Logger.debug("Assigning nil to conn account")
          assign(conn, :account, nil)
      end
    end
  end
end
