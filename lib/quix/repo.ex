defmodule Quix.Repo do
  use AshPostgres.Repo,
    otp_app: :quix

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
