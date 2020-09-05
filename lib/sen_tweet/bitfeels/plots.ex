defmodule SenTweet.Bitfeels.Plots do
  alias Contex.{Dataset, BarChart, Plot}

  @colors ["63595c"]
  @tick_precision 2

  def create(histogram) do
    histogram
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
  end

  defp create_canvas(plot_content) do
    Plot.new(600, 400, plot_content)
  end
end
