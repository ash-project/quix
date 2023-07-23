defmodule Quix.Question do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  postgres do
    table "questions"
    repo Quix.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
    end

    attribute :order, :integer do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :quiz, Quix.Quiz do
      allow_nil? false
    end
  end
end
