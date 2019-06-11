defmodule SenTweetWeb.TweetChannel do
  use Phoenix.Channel

  def join("room:tweets", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _room, _params, _socket) do
    {:error, %{reason: "not available"}}
  end

  def broadcast_tweet(tweet) when is_map(tweet) do
    sentweet =
      tweet
      |> Map.put("id", "#{tweet["id"]}")
      |> Map.put("sentiment", tweet["sentiment"] || "")
      |> Map.put("score", format_score(tweet["score"]))
      |> Map.put("score_style", score_style(tweet["score"]))

    SenTweetWeb.Endpoint.broadcast("room:tweets", "new_tweet", sentweet)
  end

  defp format_score(nil), do: ""
  defp format_score(score), do: "#{round(score * 100)}%"

  defp score_style(nil),
    do: %{"color" => "", "emoji" => ""}
  defp score_style(score) when score > 0.75,
    do: %{"color" => "#23d160", "emoji" => "&#x1F911;"}
  defp score_style(score) when score < 0.75 and score > 0.25,
    do: %{"color" => "#6cc38a", "emoji" => "&#x1F642;"}
  defp score_style(score) when score < 0.25 and score > -0.25,
    do: %{"color" => "#b5b5b5", "emoji" => "&#x1F610;"}
  defp score_style(score) when score < -0.25 and score > -0.75,
    do: %{"color" => "#da768a", "emoji" => "&#x1F928;"}
  defp score_style(score) when score < -0.75,
    do: %{"color" => "#ff3860", "emoji" => "&#x1F92C;"}
end
