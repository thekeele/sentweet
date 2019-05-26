defmodule SenTweet.Bitfeels do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_info({:tweet, {_tweet_id, tweet}}, opts) do
    SenTweet.TweetChannel.broadcast_tweet(tweet)

    {:noreply, opts}
  end
end
