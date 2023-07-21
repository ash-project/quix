defmodule Quix.Repo do
  use Ecto.Repo,
    otp_app: :quix,
    adapter: Ecto.Adapters.Postgres
end
