defmodule Quix.Quiz do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  resource do
    description "Some description of the resource"
  end

  json_api do
    type "quiz"

    routes do
      base "/quizzes"

      index :read
    end
  end

  graphql do
    type :quiz

    queries do
      list :list_quizzes, :read
    end

    mutations do
      create :create_quiz, :create
    end
  end

  actions do
    default_accept [:title]
    defaults [:create, :destroy]

    read :read do
      description "Get a list of quizzes"
      primary? true
    end

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
    end
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
  end
end
