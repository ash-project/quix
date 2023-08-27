defmodule Quix.Question do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:order, :text, :options, :correct_option]
  end

  postgres do
    table "questions"
    repo Quix.Repo

    references do
      reference :quiz, on_delete: :delete, on_update: :update
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
    end

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :options, {:array, Quix.Question.Types.Option} do
      allow_nil? false
      default []
    end

    attribute :correct_option, :string
  end

  relationships do
    belongs_to :quiz, Quix.Quiz do
      allow_nil? false
    end
  end

  validations do
    validate Quix.Question.Validations.ValidateCorrectOption
  end
end
