# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures bitfeels application
config :bitfeels, :twitter_stream,
  track: "bitcoin",
  language: "en",
  filter_level: "none",
  sink: SenTweet.Bitfeels

config :sen_tweet,
  ecto_repos: [SenTweet.Repo]

# Configures the endpoint
config :sen_tweet, SenTweetWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i5dWZ8vZk0YLlnQZ88NP5zNAxuBh8K1cF9rgIVoh+ngUBjkJ28a82ZYb9Lqy3m0y",
  render_errors: [view: SenTweetWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SenTweet.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"