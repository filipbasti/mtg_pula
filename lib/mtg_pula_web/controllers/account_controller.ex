defmodule MtgPulaWeb.AccountController do
  use MtgPulaWeb, :controller

  alias MtgPula.Accounts
  alias MtgPula.Accounts.Account
  alias MtgPula.{Users, Users.User}
  alias MtgPulaWeb.{Auth.Guardian, Auth.ErrorResponse}
  require Logger

  import MtgPulaWeb.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update, :delete]

  action_fallback MtgPulaWeb.FallbackController





  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
    {:ok, %User{} = _user} <- Users.create_user(account, account_params)
     do
      authorize_account(conn, account.email, account_params["hash_password"])
    end
  end
  def sign_in(conn, %{"email" => email, "hash_password" => hash_password})do
    authorize_account(conn, email, hash_password)
   end
   def authorize_account(conn, email, hash_password) do
   case Guardian.authenticate(email, hash_password) do


    {:ok, account, token} ->
      conn
      |> Plug.Conn.put_session(:account_id, account.id)
      |> put_status(:ok)
      |>render(:show2, account: account, token: token)

      Logger.debug("Setting session for account ID: #{account.id}")
    {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "Email or password incorrect."
   end
  end

  def sign_out(conn, %{})do

    account = conn.assigns[:account]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)
    conn
    |>Plug.Conn.clear_session()
    |> put_status(:ok)
    |>render(:show2, account: account, token: token)
  end


  def refresh_session(conn, %{}) do
    token = Guardian.Plug.current_token(conn)

    case Guardian.authenticate(token) do
      {:ok, new_token, account} ->
        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show2, account: account, token: new_token)
      {:error, :not_found} ->
        raise ErrorResponse.NotFound, message: "Token not found"
    end
  end
  def show(conn, %{"id" => id}) do
    account = Accounts.get_full_account(id)
    render(conn, :show_full_account, account: account)
  end
  def current_account(conn, %{}) do
    Logger.debug("Current account action called")
    Logger.debug("Conn assigns: #{inspect(conn.assigns)}")
    account = conn.assigns[:account]
    Logger.debug("Current account: #{inspect(account)}")
    render(conn, :show_full_account, account: account)
  end
  def update(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
