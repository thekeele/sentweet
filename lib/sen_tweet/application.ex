defmodule SenTweet.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # SenTweet.Repo,
      SenTweetWeb.Endpoint,
      {SenTweet.Bitfeels, []}
    ]

    opts = [strategy: :one_for_one, name: SenTweet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SenTweetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end