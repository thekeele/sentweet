defmodule SenTweetWeb.Router do
  use SenTweetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SenTweetWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :basic_auth, username: "bitfeels", password: "password"
  end

  scope "/", SenTweetWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/live", PageLive, :index
  end

  scope "/admin", SenTweetWeb do
    pipe_through [:browser, :auth]

    live_dashboard "/dashboard"
  end
end
