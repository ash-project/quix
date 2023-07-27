defmodule Quix.Question.Validations.ValidateCorrectOption do
  use Ash.Resource.Validation

  def validate(changeset, _) do
    options =
      changeset
      |> Ash.Changeset.get_attribute(:options)
      |> List.wrap()

    if Enum.empty?(options) do
      :ok
    else
      require_correct_option(changeset)
    end
  end

  defp require_correct_option(changeset) do
    if Ash.Changeset.get_attribute(changeset, :correct_option) do
      :ok
    else
      {:error,
       Ash.Error.Changes.Required.exception(
         field: :correct_option,
         type: :attribute,
         resource: changeset.resource
       )}
    end
  end
end
