defmodule Quix.Repo.Migrations.CreateQuizzes do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:quizzes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :title, :text, null: false
    end
  end

  def down do
    drop table(:quizzes)
  end
end
