defmodule MtgPulaWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint MtgPulaWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MtgPula.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MtgPula.Repo, {:shared, self()})
    end

    :ok
  end
end
