defmodule QuixWeb.JsonApiRouter do
  use AshJsonApi.Api.Router,
    # The api modules you want to serve
    apis: [Quix],
    prefix: "/api/json",
    # optionally a json_schema route
    json_schema: "/json_schema",
    # optionally an open_api route
    open_api: "/open_api"
end
