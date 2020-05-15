defmodule SenTweetWeb.Telemetry do
  @moduledoc """
  Collect and aggregate system metrics for the dashboard

  Details on how this module is constructed
  https://hexdocs.pm/phoenix_live_dashboard/metrics.html

  Details on the individual metrics
  https://hexdocs.pm/telemetry_metrics/Telemetry.Metrics.html#content
  """
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add reporters as children of your supervision tree.
      {SenTweet.Metrics, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Bitfeels Pipeline Source Metrics
      counter("bitfeels.pipeline.source.id", tags: [:track]),

      # Bitfeels Pipeline Dispatcher Metrics
      last_value("bitfeels.pipeline.dispatcher.enqueue.queue_length"),
      last_value("bitfeels.pipeline.dispatcher.enqueue.pending_demand"),

      last_value("bitfeels.pipeline.dispatcher.dequeue.queue_length"),
      last_value("bitfeels.pipeline.dispatcher.dequeue.demand"),
      last_value("bitfeels.pipeline.dispatcher.dequeue.events"),

      # Bitfeels Pipeline Sentiment Metrics
      last_value("bitfeels.pipeline.sentiment.number_of_events"),
      counter("bitfeels.pipeline.sentiment.id", tags: [:track]),
      summary("bitfeels.pipeline.sentiment.score", tags: [:track]),
      sum("bitfeels.pipeline.sentiment.score", tags: [:tweet_type]),

      # Bitfeels Tweet Parser Metrics
      counter("bitfeels.tweet.parser.id", tags: [:tweet_type]),

      # Bitfeels Tweet Sentiment Metrics
      summary("bitfeels.tweet.sentiment.senpy_response_time", unit: {:microsecond, :millisecond})
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {HelloWeb, :count_users, []}
    ]
  end
end
