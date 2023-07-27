defmodule Quix.Guess do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "guesses"
    repo Quix.Repo
  end

  actions do
    defaults [:read]
    
    create :upsert do
      accept [:quiz_attempt_id, :question_id, :option]
      upsert? true
      upsert_identity :unique_question_attempt
    end
  end
  
  identities do
    identity :unique_question_attempt, [:quiz_attempt_id, :question_id]
  end

  attributes do
    uuid_primary_key :id
    
    attribute :option, :string do
      allow_nil? false
    end
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

  code_interface do
    define_for Quix
    define :upsert, args: [:quiz_attempt_id, :question_id, :option]
  end
end
