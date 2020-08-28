defmodule SenTweet.Bitfeels.Metrics do
  @moduledoc """
  Handles Bitfeels Metric Events
  """

  alias SenTweet.Bitfeels.MetricServer
  alias SenTweet.Bitfeels.Stats
  alias SenTweetWeb.MetricChannel

  def create_metrics do
    Stats.create()
  end

  def handle_event([:bitfeels, :pipeline, :source], _measurements, metadata) do
    MetricServer.init_metrics(metadata)
  end

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    metadata
    |> MetricServer.get_metrics()
    |> Stats.update_score(measurements, metadata)
    |> Stats.update_metadata(measurements, metadata)
    |> MetricServer.update_metrics(metadata)
    |> MetricChannel.broadcast_metrics()
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end
end
