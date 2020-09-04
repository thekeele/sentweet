defmodule SenTweet.Bitfeels.Plots do
  alias SenTweet.Bitfeels.Stats

  def create(stats \\ Stats.create()) do
    hist = stats[:text][:likes][:histogram]
    data = Enum.map(hist, fn [l, r, c] -> [(l + r) / 2, c] end)
    dataset = Contex.Dataset.new(data)
    plot_content = Contex.BarChart.new(dataset)
    plot = Contex.Plot.new(600, 400, plot_content)
    svg = Contex.Plot.to_svg(plot)
  end
end
