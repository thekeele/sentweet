defmodule SenTweet.Bitfeels.Stats do
  @moduledoc """
  Handles updates and initialization of the sentiment statistics
  """

  @tweet_types [:extended_tweet, :retweeted_status, :quoted_status, :text]
  @weight_factors [:tweets, :likes, :retweets]

  @doc """
  Create an empty stats structure
  """
  def create do
    for type <- @tweet_types, into: %{}, do: {type, empty_stats()}
  end

  defp empty_stats do
    for factor <- @weight_factors,
        into: %{},
        do: {factor, %{count: 0, sum: 0, average: 0, histogram: empty_histogram()}}
  end

  defp empty_histogram do
    Enum.map(0..10, &[-1 + 2 * &1 / 11, -1 + 2 * (&1 + 1) / 11, 0])
  end

  @doc """
  Given existing stats and a new set of measurements, update the score
  """
  def update_score(stats, measurements, %{tweet_type: type} = metadata) do
    type = String.to_existing_atom(type)

    %{stats | type => update_type_stats(stats[type], measurements.score, metadata)}
  end

  defp update_type_stats(type_stats, score, metadata) do
    Enum.reduce(@weight_factors, %{}, fn factor, new_type_stats ->
      Map.put(
        new_type_stats,
        factor,
        update_weighted_stats(type_stats[factor], score, Map.get(metadata, factor, 1))
      )
    end)
  end

  defp update_weighted_stats(stats, score, weight) when weight > 0 do
    %{
      count: stats.count + weight,
      sum: stats.sum + weight * score,
      average: 100 * (stats.sum + score * weight) / (stats.count + weight),
      histogram: update_histogram(stats.histogram, score, weight)
    }
  end

  defp update_weighted_stats(stats, _score, weight) when weight == 0 do
    stats
  end

  defp update_histogram(histogram, score, weight) do
    histogram
    |> Enum.map(fn
      [left, right, count] when score >= left and score < right ->
        [left, right, count + weight]

      bin ->
        bin
    end)
  end

  @doc """
  Given existing stats and a new set of measurements, update non-score data
  """
  def update_metadata(stats, measurements, metadata) do
    stats
    |> Map.put(:user, metadata.user)
    |> Map.put(:track, metadata.track)
    |> Map.put(:last_metric_at, measurements.time)
  end

  @doc """
  Given a list of stats, aggregate the data into one stat

  Examples

      iex> hourly_stats = for hour <- 0..23, into: %{}, do: {hour, SenTweet.Bitfeels.Stats.create()}
      %{
      ...
      }

      iex> SenTweet.Bitfeels.Stats.aggregate(hourly_stats)
      %{
      ...
      }
  """
  def aggregate(hourly_stats) do
    hourly_stats
    |> Map.values()
    |> Enum.reduce(%{}, &aggregate_data/2)
  end

  defp aggregate_data(existing_stats, aggregated_stats) do
    Map.merge(aggregated_stats, existing_stats, &aggregate_types/3)
  end

  defp aggregate_types(_type, left, right) do
    Map.merge(left, right, &aggregate_weights/3)
  end

  defp aggregate_weights(_weight, left, right) do
    aggregated_count = left.count + right.count
    aggregated_sum = left.sum + right.sum
    aggregated_average = average(aggregated_sum, aggregated_count)
    aggregated_histogram = aggregate_histograms(left.histogram, right.histogram)

    %{
      count: aggregated_count,
      sum: aggregated_sum,
      average: aggregated_average,
      histogram: aggregated_histogram
    }
  end

  defp average(_sum, 0),
    do: 0

  defp average(sum, count),
    do: 100 * (sum / count)

  defp aggregate_histograms([], []), do: []

  defp aggregate_histograms(
         [[lower_bound, upper_bound, left_count] | rest_left],
         [[_, _, right_count] | rest_right]
       ) do
    bin = [lower_bound, upper_bound, left_count + right_count]

    [bin | aggregate_histograms(rest_left, rest_right)]
  end
end
