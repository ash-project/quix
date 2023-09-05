defmodule QuixWeb.Quix.Router do
  use AshJsonApi.Api.Router,
    apis: [Quix],
    json_schema: "/json_schema",
    open_api: "/open_api"
end
