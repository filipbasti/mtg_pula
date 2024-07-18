defmodule MtgPula.Repo do
  use Ecto.Repo,
    otp_app: :mtg_pula,
    adapter: Ecto.Adapters.Postgres
end
