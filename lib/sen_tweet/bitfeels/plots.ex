defmodule SenTweet.Bitfeels.Plots do
  alias SenTweet.Bitfeels.Stats
  alias SenTweet.Bitfeels.Stats.Data

  def create(stats \\ Data.hourly_stats(), params \\ %{}) do
    agg_histogram(stats, params)
    |> merge_bin_edges()
    |> Contex.Dataset.new()
    |> Contex.BarChart.new()
    |> create_canvas()
    |> Contex.Plot.to_svg()
  end

  defp agg_histogram(stats, %{tweet_type: tweet_type, weight: weight}) do
    Stats.aggregate(stats)[tweet_type][weight][:histogram]
  end

  defp agg_histogram(stats, _params) do
    Stats.aggregate(stats)[:extended_tweet][:tweets][:histogram]
  end

  defp merge_bin_edges(histogram) do
    Enum.map(histogram, fn [left, right, count] -> [(left + right) / 2, count] end)
  end

  defp create_canvas(plot_content) do
    Contex.Plot.new(600, 400, plot_content)
  end

end
