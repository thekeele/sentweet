defmodule SenTweetWeb.Router do
  use SenTweetWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {SenTweetWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(:dashboard_auth)
  end

  scope "/", SenTweetWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    live("/live", PageLive, :index)
  end

  scope "/admin", SenTweetWeb do
    pipe_through([:browser, :auth])
    live_dashboard("/dashboard", metrics: SenTweetWeb.Telemetry)
    resources("/streams", StreamController, only: [:index, :new, :create, :delete])
  end

  defp dashboard_auth(conn, _opts) do
    with {"bitfeels" = user, user_password} <- Plug.BasicAuth.parse_basic_auth(conn),
         dashboard_password when is_binary(dashboard_password) <-
           System.get_env("SENTWEET_DASHBOARD_PASSWORD"),
         true <- Plug.Crypto.secure_compare(user_password, dashboard_password) do
      assign(conn, :current_user, user)
    else
      _invalid -> conn |> Plug.BasicAuth.request_basic_auth() |> halt()
    end
  end
end
