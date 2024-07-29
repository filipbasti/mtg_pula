defmodule MtgPulaWeb.Auth.ErrorResponse.Unauthorized do
  defexception [message: "Unauthorized", plug_status: 401]
end
defmodule MtgPulaWeb.Auth.ErrorResponse.Forbidden do
  defexception [message: "You dont have acess to this resource", plug_status: 403]
end
defmodule MtgPulaWeb.Auth.ErrorResponse.NotFound do
  defexception [message: "Not found", plug_status: 404]
end
