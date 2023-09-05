defmodule Quix.Accounts do
  use Ash.Api

  resources do
    resource Quix.Accounts.User
    resource Quix.Accounts.Token
  end
end
