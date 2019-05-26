defmodule SenTweet.Repo do
  use Ecto.Repo,
    otp_app: :sen_tweet,
    adapter: Ecto.Adapters.Postgres
end
