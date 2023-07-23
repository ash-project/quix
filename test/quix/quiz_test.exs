defmodule Quix.QuizTest do
  use Quix.DataCase

  describe "quizzes" do
    test "a quiz can be created" do
      assert %{title: "Ash Resource Basics"} = Quix.Quiz.create!("Ash Resource Basics")
    end

    test "quizzes can be updated" do
      assert %{title: "Ash Resource Basics"} = quiz = Quix.Quiz.create!("Ash Resource Basics")

      assert %{title: "Ash Resource Advanced Topics"} =
               Quix.Quiz.update!(quiz, %{title: "Ash Resource Advanced Topics"})
    end

    test "quizzes can be read" do
      assert %{title: "Ash Resource Basics"} = Quix.Quiz.create!("Ash Resource Basics")

      assert %{title: "Ash Resource Advanced Topics"} =
               Quix.Quiz.create!("Ash Resource Advanced Topics")

      assert [%{title: "Ash Resource Advanced Topics"}, %{title: "Ash Resource Basics"}] =
               Quix.Quiz |> Ash.Query.sort(title: :asc) |> Quix.read!()
    end

    test "a quiz can be destroyed" do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")
      assert :ok = Quix.Quiz.destroy!(quiz)

      assert_raise Ash.Error.Query.NotFound, ~r/record not found/, fn ->
        Quix.Quiz.by_id!(quiz.id)
      end
    end
  end
end
