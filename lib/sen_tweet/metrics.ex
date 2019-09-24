defmodule SenTweet.Metrics do
  use GenServer

  alias SenTweetWeb.MetricChannel

  @tab :bitfeels_events
  @metric_pull_interval 1000 * 30 # millisecond to seconds (30 seconds)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_work(0)

    {:ok, state}
  end

  @impl true
  def handle_info(:compute_metrics, state) do

    metrics = compute_metrics()

    MetricChannel.broadcast_metrics(metrics)

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work(interval \\ @metric_pull_interval) do
    Process.send_after(self(), :compute_metrics, interval)
  end

  defp compute_metrics() do
    scores = lookup_scores()
    num_scores = length(scores)
    sum_scores = Enum.sum(scores)
    average_score = (sum_scores / num_scores) * 100

    %{num_scores: num_scores, average_score: average_score}
  end

  defp lookup_scores(key \\ "bitfeels_pipeline_sentiment") do
    @tab
    |> :ets.lookup(key)
    |> Enum.map(fn {_key, _id, score, _time} -> score end)
  end
end
