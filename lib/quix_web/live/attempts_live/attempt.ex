defmodule QuixWeb.AttemptsLive.Attempt do
  use QuixWeb, :live_view
  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @quiz.title %>
    </.header>

    <%= for question <- @quiz.questions do %>
      <p><%= question.text %></p>
      <div class="flex flex-row space-x-2">
        <%= for option <- question.options do %>
          <.button
            phx-click="make-guess"
            class={guess_button_class(@attempt, question, option)}
            phx-value-question={question.id}
            phx-value-option={option.name}
          >
            <%= option.name %>. <%= option.text %>
          </.button>
        <% end %>
      </div>
      <hr />
    <% end %>

    <.button phx-click="finish" class="mt-8">
      Submit
    </.button>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Quiz")
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(%{"quiz" => quiz_id}, _uri, socket) do
    {:noreply, assign_quiz_and_attempt(socket, quiz_id)}
  end

  @impl true
  def handle_event("make-guess", %{"question" => question_id, "option" => option}, socket) do
    Quix.QuizAttempt.make_guess!(socket.assigns.attempt, question_id, option)
    {:noreply, assign_quiz_and_attempt(socket, socket.assigns.quiz.id)}
  end

  @impl true
  def handle_event("finish", _, socket) do
    Quix.QuizAttempt.finish!(socket.assigns.attempt)

    {:noreply, redirect(socket, to: "/")}
  end

  defp assign_quiz_and_attempt(socket, quiz_id) do
    attempts_query =
      Quix.QuizAttempt
      |> Ash.Query.load(:guesses)
      |> Ash.Query.filter(user_id == ^socket.assigns.current_user.id)

    quiz = Quix.Quiz.by_id!(quiz_id, load: [:questions, active_attempts: attempts_query])

    attempt = case Enum.at(quiz.active_attempts, 0) do
      nil ->
        quiz_id
        |> Quix.QuizAttempt.start!(actor: socket.assigns.current_user)
        |> Map.put(:guesses, [])
      attempt ->
      attempt
    end

    assign(socket, quiz: quiz, attempt: attempt)
  end

  defp guess_button_class(attempt, question, option) do
    case Enum.find(attempt.guesses, &(&1.question_id == question.id)) do
      nil ->
        ""
      guess ->
        if guess.option == option.name do
          "ring-4 ring-blue-500"
        else
          ""
        end
    end

  end
end
