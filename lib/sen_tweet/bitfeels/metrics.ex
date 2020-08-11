defmodule SenTweet.Bitfeels.Metrics do
  @moduledoc """
  Handles Bitfeels Metric Events
  """

  alias SenTweet.Bitfeels.MetricServer
  alias SenTweetWeb.MetricChannel

  @tweet_types ["extended_tweet", "retweeted_status", "quoted_status", "text"]

  def create_metrics do
    for type <- @tweet_types, into: %{}, do: {type, default_metrics()}
  end

  def handle_event([:bitfeels, :pipeline, :source], _measurements, metadata) do
    MetricServer.init_metrics(metadata)
  end

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    metadata
    |> MetricServer.get_metrics()
    |> calculate_metrics(measurements, metadata)
    |> MetricServer.update_metrics(metadata)
    |> MetricChannel.broadcast_metrics()
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end

  defp calculate_metrics(metrics, measurements, %{tweet_type: type} = metadata) do
    %{
      metrics
      | type =>
          update_stats(measurements.score, metrics[type])
          |> Map.put(:user, metadata.user)
          |> Map.put(:track, metadata.track)
          |> Map.put(:last_metric_at, measurements.time)
    }
  end

  defp update_stats(score, metrics) do
    %{
      tweets_processed: metrics.tweets_processed + 1,
      sum_scores: metrics.sum_scores + score,
      average_score: 100 * (metrics.sum_scores + score) / (metrics.tweets_processed + 1),
      histogram: update_histogram(score, metrics.histogram)
    }
  end

  defp update_histogram(score, histogram) do
    histogram
    |> Enum.map(fn
      [left, right, count] when score >= left and score < right ->
        [left, right, count + 1]

      bin ->
        bin
    end)
  end

  defp default_metrics do
    %{
      tweets_processed: 0,
      sum_scores: 0,
      average_score: 0,
      histogram: Enum.map(0..10, &[-1 + 2 * &1 / 11, -1 + 2 * (&1 + 1) / 11, 0])
    }
  end
end
