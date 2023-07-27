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

  describe "questions" do
    test "questions can be managed on a quiz" do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")

      text1 =
        "What is the default value of the `allow_nil?` option of attributes on `Ash.Resource`"

      text2 =
        "What is the name of the option used to modify/build a changeset within a create/update/destroy action?"

      assert %{questions: [%{text: ^text1, order: 0}, %{text: ^text2, order: 1}]} =
               Quix.Quiz.update!(quiz, %{
                 questions: [
                   %{
                     text: text1
                   },
                   %{
                     text: text2
                   }
                 ]
               })
    end

    test "questions can include options" do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")

      text1 =
        "What is the default value of the `allow_nil?` option of attributes on `Ash.Resource`"

      text2 =
        "What is the name of the option used to modify/build a changeset within a create/update/destroy action?"

      assert %{
               questions: [
                 %{
                   text: ^text1,
                   order: 0,
                   options: [
                     %{name: "A", text: "true"},
                     %{name: "B", text: "false"}
                   ]
                 },
                 %{
                   text: ^text2,
                   order: 1,
                   options: [
                     %{name: "A", text: "prepare"},
                     %{name: "B", text: "change"},
                     %{name: "C", text: "validate"},
                     %{name: "D", text: "accept"}
                   ]
                 }
               ]
             } =
               Quix.Quiz.update!(quiz, %{
                 questions: [
                   %{
                     text: text1,
                     options: [
                       %{name: "A", text: "true"},
                       %{name: "B", text: "false"}
                     ],
                     correct_option: "A"
                   },
                   %{
                     text: text2,
                     options: [
                       %{name: "A", text: "prepare"},
                       %{name: "B", text: "change"},
                       %{name: "C", text: "validate"},
                       %{name: "D", text: "accept"}
                     ],
                     correct_option: "B"
                   }
                 ]
               })
    end

    test "quizzes cannot be published if their questions do not have correct answers" do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")

      text1 =
        "What is the default value of the `allow_nil?` option of attributes on `Ash.Resource`"

      quiz =
        Quix.Quiz.update!(quiz, %{
          questions: [
            %{
              text: text1,
              options: []
            }
          ]
        })

      assert_raise Ash.Error.Invalid, ~r/all questions must have a correct option/, fn ->
        Quix.Quiz.publish!(quiz)
      end
    end

    test "quizzes can be published if their questions have correct answers" do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")

      text1 =
        "What is the default value of the `allow_nil?` option of attributes on `Ash.Resource`"

      quiz =
        Quix.Quiz.update!(quiz, %{
          questions: [
            %{
              text: text1,
              options: [
                %{name: "A", text: "true"},
                %{name: "B", text: "false"}
              ],
              correct_option: "A"
            }
          ]
        })

      assert %{state: :published} = Quix.Quiz.publish!(quiz)
    end
  end

  describe "quiz attempts" do
    setup do
      assert quiz = Quix.Quiz.create!("Ash Resource Basics")

      text1 =
        "What is the default value of the `allow_nil?` option of attributes on `Ash.Resource`"

      %{questions: [question]} =
        quiz =
        Quix.Quiz.update!(quiz, %{
          questions: [
            %{
              text: text1,
              options: [
                %{name: "A", text: "true"},
                %{name: "B", text: "false"}
              ],
              correct_option: "A"
            }
          ]
        })

      %{quiz: quiz, question: question}
    end

    test "a quiz attempt can be started", %{quiz: quiz} do
      assert %{finished: false} = Quix.QuizAttempt.start!(quiz.id)
    end

    test "a guess can be made on a quiz", %{quiz: quiz, question: question} do
      attempt = Quix.QuizAttempt.start!(quiz.id)

      assert %{guesses: [guess]} =
               Quix.QuizAttempt.make_guess!(attempt, question.id, "B") |> Quix.load!(:guesses)

      assert guess.question_id == question.id
      assert guess.option == "B"
    end

    test "a quiz can be finished", %{quiz: quiz, question: question} do
      attempt = Quix.QuizAttempt.start!(quiz.id)
      Quix.QuizAttempt.make_guess!(attempt, question.id, "B") |> Quix.load!(:guesses)

      assert %{finished: true} = Quix.QuizAttempt.finish!(attempt)
    end

    test "a finished quiz can be graded", %{quiz: quiz, question: question} do
      attempt =
        quiz.id
        |> Quix.QuizAttempt.start!()
        |> Quix.QuizAttempt.make_guess!(question.id, "B")
        |> Quix.QuizAttempt.finish!()
        |> Quix.load!(:score)

      assert Decimal.eq?(attempt.score, 0)

      attempt =
        quiz.id
        |> Quix.QuizAttempt.start!()
        |> Quix.QuizAttempt.make_guess!(question.id, "A")
        |> Quix.QuizAttempt.finish!()
        |> Quix.load!(:score)

      assert Decimal.eq?(attempt.score, 1)
    end
  end
end
