defmodule SenTweet.Bitfeels.Metrics do
  @moduledoc """
  Handles Bitfeels Metric Events
  """

  alias SenTweet.Bitfeels.MetricServer
  alias SenTweetWeb.MetricChannel

  def create_metrics do
    for type <- ["extended_tweet", "retweeted_status", "quoted_status", "text"], into: %{}, do:
    {type, %{
      tweets_processed: 0,
      sum_scores: 0,
      average_score: 0,
      histogram: Enum.map(0..10, &[-1 + 2 * &1 / 11, -1 + 2 * (&1 + 1) / 11, 0])
    }}
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

    current_metrics = metrics[type]
    tweets_processed = current_metrics.tweets_processed + 1
    sum_scores = current_metrics.sum_scores + measurements.score
    average_score = sum_scores / tweets_processed * 100
    histogram = update_histogram(measurements.score, current_metrics.histogram)

    metrics
    |> Map.put(type, current_metrics
      |> Map.put(:user, metadata.user)
      |> Map.put(:track, metadata.track)
      |> Map.put(:last_metric_at, measurements.time)
      |> Map.put(:tweets_processed, tweets_processed)
      |> Map.put(:sum_scores, sum_scores)
      |> Map.put(:average_score, average_score)
      |> Map.put(:histogram, histogram)
    )
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
end
