defmodule SenTweetWeb.TweetChannel do
  use Phoenix.Channel

  def join("room:tweets", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _room, _params, _socket) do
    {:error, %{reason: "not available"}}
  end

  def broadcast_tweet(tweet) when is_map(tweet) do
    SenTweetWeb.Endpoint.broadcast("room:tweets", "new_tweet", tweet)
  end
end
