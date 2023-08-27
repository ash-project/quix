defmodule Quix.Accounts do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show? true
  end

  resources do
    resource Quix.Accounts.User
    resource Quix.Accounts.Token
  end
end
