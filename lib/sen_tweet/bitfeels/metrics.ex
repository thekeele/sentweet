defmodule SenTweet.Bitfeels.Metrics do
  @moduledoc """
  Handles Bitfeels Metric Events
  """

  alias SenTweet.Bitfeels.MetricServer
  alias SenTweetWeb.MetricChannel

  @tweet_types ["extended_tweet", "retweeted_status", "quoted_status", "text"]
  @tracks [:tweet_scores, :like_scores, :retweet_scores]

  def create_metrics do
    for type <- @tweet_types, into: %{}, do: {type, default_metrics()}
  end

  def default_metrics do
    for track <- @tracks, into: %{}, do:
      {track, %{count: 0, sum: 0, average: 0, histogram: init_histogram()}}
  end

  defp init_histogram do
    Enum.map(0..10, &[-1 + 2 * &1 / 11, -1 + 2 * (&1 + 1) / 11, 0])
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
    m = %{
      metrics
      | type =>
          update_stats(measurements.score, metrics[type], metadata)
          |> Map.put(:user, metadata.user)
          |> Map.put(:track, metadata.track)
          |> Map.put(:last_metric_at, measurements.time)
    }
    IO.puts("done!")
    IO.inspect(m)
    m
  end

  defp update_stats(score, metrics, metadata) do
    IO.inspect(metrics)
    new_stats = %{}

    for track <- @tracks do
      weight = if(track == :tweets, do: 1, else: Map.get(metadata, track, 0))
      count = metrics[track].count + weight
      sum = metrics[track].sum + weight * score
      average = if(count > 0, do: sum / count, else: 0)
      histogram = update_histogram(score, weight, metrics[track].histogram)
      Map.put(new_stats, track, %{count: count, sum: sum, average: average, histogram: histogram})
    end
    IO.inspect(new_stats)
    new_stats
  end

  defp update_histogram(score, weight, histogram) do
    histogram
    |> Enum.map(fn
      [left, right, count] when score >= left and score < right ->
        [left, right, count + weight]

      bin ->
        bin
    end)
  end

end
