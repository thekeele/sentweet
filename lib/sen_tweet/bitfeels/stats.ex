defmodule SenTweet.Bitfeels.Stats do
  @tweet_types [:extended_tweet, :retweeted_status, :quoted_status, :text]
  @weight_factors [:tweets, :likes, :retweets]

  def create_stats do
    for type <- @tweet_types, into: %{}, do: {type, empty_stats()}
  end

  def update_all_stats(all_stats, measurements, %{tweet_type: type} = metadata) do
    type = String.to_atom(type)

    %{
      all_stats
      | type =>
          update_type_stats(all_stats[type], measurements.score, metadata)
          |> Map.put(:user, metadata.user)
          |> Map.put(:track, metadata.track)
          |> Map.put(:last_metric_at, measurements.time)
    }
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
      average: 100 * (stats.sum + weight) / (stats.count + weight),
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

  defp empty_stats do
    for factor <- @weight_factors,
        into: %{},
        do: {factor, %{count: 0, sum: 0, average: 0, histogram: empty_histogram()}}
  end

  defp empty_histogram do
    Enum.map(0..10, &[-1 + 2 * &1 / 11, -1 + 2 * (&1 + 1) / 11, 0])
  end
end
