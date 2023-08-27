defmodule QuixWeb.QuizLive.FormComponent do
  use QuixWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage quiz records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="quiz-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:title]} type="text" label="Title" />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:title]} type="text" label="Title" />
          <h2>Questions</h2>
          <div class="ml-4">
            <.inputs_for :let={question_form} field={@form[:questions]}>
              <.input field={question_form[:text]} type="text" label="Question" />
              <.input
                type="select"
                field={question_form[:correct_option]}
                options={all_options(question_form)}
                disabled={Enum.empty?(all_options(question_form))}
                label="Correct Option"
              />
              <h2>Options</h2>
              <div class="ml-4">
                <.inputs_for :let={option_form} field={question_form[:options]}>
                  <.input field={option_form[:name]} type="text" label="Name" />
                  <.input field={option_form[:text]} type="text" label="Text" />
                </.inputs_for>
              </div>
              <.button
                type="button"
                phx-click="add_option"
                phx-value-name={question_form.name}
                phx-target={@myself}
              >
                <.icon name="hero-plus" class="h-4 w-4" />
              </.button>
            </.inputs_for>
          </div>
          <.button type="button" phx-click="add_question" phx-target={@myself}>
            <.icon name="hero-plus" class="h-4 w-4" />
          </.button>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Quiz</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"quiz" => quiz_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, quiz_params))}
  end

  def handle_event("save", %{"quiz" => quiz_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: quiz_params, force?: true) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        socket =
          socket
          |> put_flash(:info, "Quiz #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("add_question", _, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.add_form(socket.assigns.form, [:questions]))}
  end

  def handle_event("add_option", %{"name" => name}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.add_form(socket.assigns.form, name <> "[options]"))}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{quiz: quiz}} = socket) do
    form =
      if quiz do
        quiz = Quix.load!(quiz, [:questions], lazy?: true)
        AshPhoenix.Form.for_update(quiz, :update, api: Quix, as: "quiz", forms: [auto?: true])
      else
        AshPhoenix.Form.for_create(Quix.Quiz, :create,
          api: Quix,
          as: "quiz",
          forms: [auto?: true]
        )
      end

    assign(socket, form: to_form(form))
  end

  defp all_options(form) do
    form.source.forms[:options]
    |> List.wrap()
    |> Enum.map(fn form ->
      AshPhoenix.Form.value(form, :name)
    end)
    |> Enum.reject(&is_nil/1)
  end
end
