defmodule Quix do
  use Ash.Api

  resources do
    resource Quix.Quiz
    resource Quix.Question
    resource Quix.QuizAttempt
    resource Quix.Guess
  end
end
