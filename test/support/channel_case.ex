defmodule MtgPulaWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import MtgPulaWeb.ChannelCase

      # The default endpoint for testing
      @endpoint MtgPulaWeb.Endpoint
    end
  end

  setup  do
    Ecto.Adapters.SQL.Sandbox.mode(MtgPula.Repo, :manual)

  end
end
