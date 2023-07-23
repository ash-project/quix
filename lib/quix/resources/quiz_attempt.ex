defmodule Quix.QuizAttempt do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "quiz_attempts"
    repo Quix.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :quiz, Quix.Quiz do
      allow_nil? false
      attribute_writable? true
    end

    has_many :guesses, Quix.Guess
  end
end
