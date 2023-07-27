defmodule Quix.Quiz do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

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
