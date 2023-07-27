defmodule Quix.Question.Types.Option do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :name, :string do
      allow_nil? false
    end

    attribute :text, :string do
      allow_nil? false
    end
  end
end
