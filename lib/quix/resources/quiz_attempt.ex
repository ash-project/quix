defmodule Quix.QuizAttempt do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read]

    create :start do
      accept [:quiz_id]
    end

    update :finish do
      accept []
      change set_attribute(:finished, true)
    end

    update :make_guess do
      accept []

      argument :question_id, :uuid do
        allow_nil? false
      end

      argument :option, :string do
        allow_nil? false
      end

      validate attribute_equals(:finished, false),
        message: "cannot make guesses on a finished attempt"

      change fn changeset, _ ->
        Ash.Changeset.after_action(changeset, fn _changeset, result ->
          Quix.Guess.upsert!(
            changeset.data.id,
            changeset.arguments.question_id,
            changeset.arguments.option
          )

          {:ok, result}
        end)
      end
    end
  end

  postgres do
    table "quiz_attempts"
    repo Quix.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :finished, :boolean do
      default false
    end
  end

  calculations do
    calculate :score,
              :decimal,
              expr(
                if finished == true do
                  count_of_right_answers / count_of_quiz_questions
                end
              )
  end

  aggregates do
    count :count_of_quiz_questions, [:quiz, :questions]

    count :count_of_right_answers, :guesses do
      filter expr(question.correct_option == option)
    end
  end

  relationships do
    belongs_to :quiz, Quix.Quiz do
      allow_nil? false
      attribute_writable? true
    end

    has_many :guesses, Quix.Guess
  end

  code_interface do
    define_for Quix

    define :start, args: [:quiz_id]
    define :make_guess, args: [:question_id, :option]
    define :finish
  end
end
