defmodule QuixWeb.QuizLive.Show do
  use QuixWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Quiz <%= @quiz.id %>
      <:subtitle>This is a quiz record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/quizzes/#{@quiz}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit quiz</.button>
        </.link>
      </:actions>
    </.header>

    <.back navigate={~p"/"}>Back to quizzes</.back>

    <.modal
      :if={@live_action == :edit}
      id="quiz-modal"
      show
      on_cancel={JS.patch(~p"/quizzes/#{@quiz}")}
    >
      <.live_component
        module={QuixWeb.QuizLive.FormComponent}
        id={@quiz.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        quiz={@quiz}
        patch={~p"/quizzes/#{@quiz}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:quiz, Quix.Quiz.by_id!(id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
