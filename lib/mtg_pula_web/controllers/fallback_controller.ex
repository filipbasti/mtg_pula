defmodule MtgPulaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MtgPulaWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: MtgPulaWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: MtgPulaWeb.ErrorHTML, json: MtgPulaWeb.ErrorJSON)
    |> render(:"404")
  end


  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(html: MtgPulaWeb.ErrorHTML, json: MtgPulaWeb.ErrorJSON)
    |> render(:"403")
  end

  def call(conn, :ok) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Success"})
  end
end
