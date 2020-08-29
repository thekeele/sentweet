defmodule SenTweet.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SenTweetWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SenTweet.PubSub},
      # Start the Endpoint (http/https)
      SenTweetWeb.Endpoint,
      # Start bitfeels twitter stream worker
      {SenTweet.Bitfeels, []},
      # Start bitfeels metric server
      {SenTweet.Bitfeels.MetricServer, []},
      # Start bitfeels hourly statistics server
      {SenTweet.Bitfeels.HourlyStats, []}
    ]

    opts = [strategy: :one_for_one, name: SenTweet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SenTweetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
