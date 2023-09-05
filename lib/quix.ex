defmodule Quix do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Quix.Quiz
    resource Quix.Question
    resource Quix.QuizAttempt
    resource Quix.Guess
  end
end
