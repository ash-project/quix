defmodule Quix.Quiz do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "quiz"

    routes do
      base "/quizzes"
      index :read
      post :create
      patch :update
      patch :publish, route: "/:id/publish"
    end
  end

  graphql do
    type :quiz

    queries do
      list :list_quizzes, :read
    end

    mutations do
      create :create_quiz, :create
      update :update_quiz, :update
      update :publish_quiz, :publish
    end
  end

  actions do
    default_accept [:title]
    defaults [:create, :read, :destroy]

    update :update do
      primary? true
      argument :questions, {:array, :map}

      change fn changeset, _ ->
        if changeset.arguments[:questions] do
          questions =
            changeset.arguments.questions
            |> Stream.with_index()
            |> Enum.map(fn {input, index} ->
              Map.put(input, :order, index)
            end)

          Ash.Changeset.set_argument(changeset, :questions, questions)
        else
          changeset
        end
      end

      change manage_relationship(:questions, type: :direct_control)
    end

    update :publish do
      accept []
      change Quix.Quiz.Changes.Publish
      change set_attribute(:state, :published)
    end
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

    attribute :state, :atom do
      constraints one_of: [:published, :pending]
      default :pending
      allow_nil? false
    end
  end

  calculations do
    calculate :users_latest_score,
              :decimal,
              expr(
                first(attempts,
                  field: :score,
                  query: [filter: expr(user_id == ^actor(:id)), sort: [inserted_at: :desc]]
                )
              )
    calculate :who_am_i, :string, expr(^actor(:id))
  end

  code_interface do
    define_for Quix
    define :create, args: [:title]
    define :read
    define :by_id, get_by: [:id], action: :read
    define :update
    define :destroy
    define :publish
  end

  relationships do
    has_many :questions, Quix.Question
    has_many :attempts, Quix.QuizAttempt

    has_many :active_attempts, Quix.QuizAttempt do
      filter expr(finished == false)
    end
  end
end
