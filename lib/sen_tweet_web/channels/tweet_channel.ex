defmodule SenTweetWeb.TweetChannel do
  use Phoenix.Channel

  def join("room:tweets", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _room, _params, _socket) do
    {:error, %{reason: "not available"}}
  end

  def broadcast_tweet(tweet) when is_map(tweet) do
    tweet = %{
      id: tweet["id"],
      text: tweet["text"],
      sentiment: tweet["sentiment"],
      score: tweet["score"]
    }

    SenTweetWeb.Endpoint.broadcast("room:tweets", "new_tweet", tweet)
  end
end
