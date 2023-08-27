defmodule QuixWeb.AttemptsLive.Index do
  use QuixWeb, :live_view
  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Available Quizzes
    </.header>

    <.table
      id="quizzes"
      rows={@streams.quizzes}
      row_click={fn {_id, quiz} -> JS.navigate(~p"/attempt/#{quiz}") end}
    >
      <:col :let={{_id, quiz}} label="Title"><%= quiz.title %></:col>

      <:col :let={{_id, quiz}} label="Latest Score"><%= to_percent(quiz.users_latest_score) %></:col>

      <:action :let={{_id, quiz}}>
        <div class="sr-only">
          <.link navigate={~p"/attempt/#{quiz}"}>Attempt</.link>
        </div>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    quizzes =
      Quix.Quiz
      |> Ash.Query.filter(state == :published)
      |> Quix.read!(load: [:users_latest_score], actor: socket.assigns[:current_user])

    {:ok,
     socket
     |> stream(:quizzes, quizzes)
     |> assign(:page_title, "Available Quizzes")
     |> assign_new(:current_user, fn -> nil end)}
  end

  defp to_percent(nil), do: nil

  defp to_percent(decimal) do
    decimal
    |> Decimal.mult(100)
    |> Decimal.round(2)
    |> to_string()
    |> Kernel.<>("%")
  end
end
