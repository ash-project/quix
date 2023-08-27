defmodule QuixWeb.Router do
  use QuixWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :require_authorization
  end

  pipeline :graphql do
    plug :require_authorization
    plug AshGraphql.Plug
  end

  pipeline :playground do
    plug :fetch_session
    plug :load_from_session
  end

  scope "/api/json" do
    pipe_through [:api, :require_authorization]

    forward "/", QuixWeb.JsonApiRouter
  end

  scope "/" do
    pipe_through [:graphql, :require_authorization]

    forward "/gql", Absinthe.Plug, schema: QuixWeb.Schema
  end

  scope "/" do
    pipe_through [:playground, :api]

    forward "/swaggerui",
      OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      title: "Swagger UI",
      default_model_expand_depth: 4

  end

  scope "/" do
    pipe_through [:playground, :graphql]

    forward "/playground",
      Absinthe.Plug.GraphiQL,
      schema: QuixWeb.Schema,
      interface: :playground
  end

  scope "/", QuixWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_only,
      on_mount: [{QuixWeb.LiveUserAuth, :live_user_required}] do
      live "/quizzes", QuizLive.Index, :index
      live "/quizzes/new", QuizLive.Index, :new
      live "/quizzes/:id/edit", QuizLive.Index, :edit
      live "/", AttemptsLive.Index, :index
      live "/attempt/:quiz", AttemptsLive.Attempt, :attempt

      live "/quizzes/:id", QuizLive.Show, :show
      live "/quizzes/:id/show/edit", QuizLive.Show, :edit
    end

    sign_in_route()
    sign_out_route AuthController
    auth_routes_for Quix.Accounts.User, to: AuthController
    reset_route []
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:quix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router
    import AshAdmin.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QuixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      ash_admin "/"
    end
  end

  def require_authorization(conn, _) do
    Ash.PlugHelpers.set_actor(conn, conn.assigns[:current_user])
  end
end
