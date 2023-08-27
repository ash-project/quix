defmodule Quix.Repo.Migrations.AddOptionsToQuestions do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:questions) do
      add :options, {:array, :map}, null: false, default: []
    end
  end

  def down do
    alter table(:questions) do
      remove :options
    end
  end
end
