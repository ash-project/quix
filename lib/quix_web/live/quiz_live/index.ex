defmodule QuixWeb.QuizLive.Index do
  use QuixWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Quizzes
      <:actions>
        <.link patch={~p"/quizzes/new"}>
          <.button>New Quiz</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="quizzes"
      rows={@streams.quizzes}
      row_click={fn {_id, quiz} -> JS.navigate(~p"/quizzes/#{quiz}") end}
    >
      <:col :let={{_id, quiz}} label="Id"><%= quiz.id %></:col>

      <:col :let={{_id, quiz}} label="Title"><%= quiz.title %></:col>

      <:col :let={{_id, quiz}} label="State"><%= quiz.state %></:col>

      <:action :let={{_id, quiz}}>
        <div class="sr-only">
          <.link navigate={~p"/quizzes/#{quiz}"}>Show</.link>
        </div>

        <.link patch={~p"/quizzes/#{quiz}/edit"}>Edit</.link>
      </:action>

      <:action :let={{_id, quiz}}>
        <%= if quiz.state != :published do %>
          <.link phx-click={JS.push("publish", value: %{id: quiz.id})} data-confirm="Are you sure?">
            Publish
          </.link>
        <% end %>
      </:action>
      <:action :let={{id, quiz}}>
        <.link
          phx-click={JS.push("delete", value: %{id: quiz.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="quiz-modal"
      show
      on_cancel={JS.patch(~p"/quizzes")}
    >
      <.live_component
        module={QuixWeb.QuizLive.FormComponent}
        id={(@quiz && @quiz.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        quiz={@quiz}
        patch={~p"/quizzes"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:quizzes, Quix.read!(Quix.Quiz, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quiz")
    |> assign(:quiz, Quix.Quiz.by_id!(id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quiz")
    |> assign(:quiz, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quizzes")
    |> assign(:quiz, nil)
  end

  @impl true
  def handle_info({QuixWeb.QuizLive.FormComponent, {:saved, quiz}}, socket) do
    {:noreply, stream_insert(socket, :quizzes, quiz)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Quix.Quiz.by_id!(id, actor: socket.assigns.current_user)
    Quix.destroy!(quiz, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :quizzes, quiz)}
  end

  @impl true
  def handle_event("publish", %{"id" => id}, socket) do
    quiz =
      id
      |> Quix.Quiz.by_id!(id, actor: socket.assigns.current_user)
      |> Quix.Quiz.publish!(actor: socket.assigns.current_user)

    {:noreply, stream_insert(socket, :quizzes, quiz)}
  end
end
