defmodule Quix.Quiz.Changes.Publish do
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      questions = Quix.load!(changeset.data, :questions).questions

      if Enum.all?(questions, & &1.correct_option) do
        changeset
      else
        Ash.Changeset.add_error(changeset,
          field: :questions,
          message: "all questions must have a correct option"
        )
      end
    end)
  end
end
