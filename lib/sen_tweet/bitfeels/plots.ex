defmodule SenTweet.Bitfeels.Plots do
  alias SenTweet.Bitfeels.Stats
  alias SenTweet.Bitfeels.Stats.Data
  alias Contex.{Dataset, BarChart, Plot}

  @colors ["63595c"]
  @tick_precision 2

  def create(stats \\ Data.hourly_stats(), params \\ %{}) do

    agg_histogram(stats, params)
    |> merge_bin_edges()
    |> Dataset.new()
    |> BarChart.new()
    |> BarChart.colours(@colors)
    |> BarChart.data_labels(false)
    |> BarChart.padding(4)
    |> create_canvas()
    |> Plot.axis_labels("Sentiment", "Frequency")
    |> Plot.to_svg()
  end

  defp agg_histogram(stats, %{tweet_type: tweet_type, weight: weight}) do
    Stats.aggregate(stats)[tweet_type][weight][:histogram]
  end

  defp agg_histogram(stats, _params) do
    Stats.aggregate(stats)[:extended_tweet][:tweets][:histogram]
  end

  defp format_edge(float) do
    float
    |> Float.round(@tick_precision)
    |> Float.to_string()
  end

  defp format_tick_label(left, right) do
    Enum.map([left, right], &format_edge/1)
    |> Enum.join(" to ")
  end

  defp merge_bin_edges(histogram) do
    Enum.map(histogram, fn [left, right, count] ->
      [format_tick_label(left, right), count]
    end)
    |> IO.inspect()
  end

  defp create_canvas(plot_content) do
    Plot.new(600, 400, plot_content)
  end

end
