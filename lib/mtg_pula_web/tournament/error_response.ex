defmodule MtgPulaWeb.Tournament.ErrorResponse.NotFound do
  defexception message: "Not found", plug_status: 404
end

defmodule MtgPulaWeb.Tournament.ErrorResponse.Finished do
  defexception message: "Tournament finished", plug_status: 400
end
