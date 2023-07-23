defmodule Quix.Quiz do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    default_accept [:title]
    defaults [:create, :update, :read, :destroy]
  end

  postgres do
    table "quizzes"
    repo Quix.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end
  end

  code_interface do
    define_for Quix
    define :create, args: [:title]
    define :read
    define :by_id, get_by: [:id], action: :read
    define :update
    define :destroy
  end

  relationships do
    has_many :questions, Quix.Question
  end
end
