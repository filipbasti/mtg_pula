defmodule MtgPula.Support.DataCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      alias Ecto.Changeset
      import MtgPula.Support.DataCase
      alias MtgPula.{Support.Factory, Repo}
    end
  end

  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(MtgPula.Repo, :manual)
  end
end
