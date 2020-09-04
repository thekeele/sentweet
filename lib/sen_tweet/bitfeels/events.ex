defmodule SenTweet.Bitfeels.Events do
  @moduledoc """
  Handle incoming events emitted from the bitfeels application
  """
  alias SenTweet.Bitfeels.{HourlyStats, Stats}

  @topic "SenTweetWeb.PageLive"

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    metadata
    |> HourlyStats.get()
    |> Stats.update_score(measurements, metadata)
    |> HourlyStats.put(metadata)
    |> broadcast_stats()
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end

  defp broadcast_stats(hourly_stats) do
    message = {:bitfeels, hourly_stats}

    Phoenix.PubSub.broadcast(SenTweet.PubSub, @topic, message)
  end
end
