defmodule SenTweet.Metrics do
  use GenServer

  alias SenTweetWeb.MetricChannel

  def start_link(_opts) do
    # add metrics here with an initial value
    metrics = %{
      tweets_processed: 0,
      sum_scores: 0,
      average_score: 0
    }

    GenServer.start_link(__MODULE__, metrics, name: __MODULE__)
  end

  @impl true
  def init(metrics) do
    {:ok, metrics}
  end

  @impl true
  def handle_info({:bitfeels_event, data}, metrics) do
    # here we receive event data from bitfeels
    # we then process the data and update the metrics
    metrics = handle_event(data, metrics)

    # broadcast our updated metrics to a channel in order to update the UI
    MetricChannel.broadcast_metrics(metrics)

    {:noreply, metrics}
  end

  defp handle_event({"bitfeels_pipeline_source", _id, _time}, metrics) do
    # this metrics is when a tweet first enters bitfeels
    # we could compute the time it takes for us to process a tweet
    # i.e. through bitfeels pipeline to senpytweet and back
    metrics
  end

  defp handle_event({"bitfeels_pipeline_sentiment", id, score, time}, metrics) do
    # the metrics map contains the current metrics in the state of this process
    # now we can update the current metrics with the new event data
    tweets_processed = metrics.tweets_processed + 1
    sum_scores = metrics.sum_scores + score
    average_score = (sum_scores / tweets_processed) * 100

    # put the updated metrics into the metrics map
    metrics
    |> Map.put(:tweets_processed, tweets_processed)
    |> Map.put(:sum_scores, sum_scores)
    |> Map.put(:average_score, average_score)
  end
end
