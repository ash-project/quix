defmodule Quix.Guess do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "guesses"
    repo Quix.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :quiz_attempt, Quix.QuizAttempt do
      allow_nil? false
      attribute_writable? true
    end

    belongs_to :question, Quix.Question do
      allow_nil? false
      attribute_writable? true
    end
  end
end
