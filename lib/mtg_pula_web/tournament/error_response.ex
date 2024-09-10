defmodule MtgPulaWeb.Tournament.ErrorResponse.NotFound do
  defexception [message: "Not found", plug_status: 404]
end
