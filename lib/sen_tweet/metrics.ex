defmodule SenTweet.Metrics do
  @moduledoc """
  Reporter module for handling individual events

  Details on how this module is constructed
  https://hexdocs.pm/telemetry_metrics/writing_reporters.html
  """
  use GenServer
  require Logger
  alias SenTweet.Bitfeels

  def start_link(opts) do
    metrics =
      opts[:metrics] ||
        raise ArgumentError, "the :metrics option is required by #{inspect(__MODULE__)}"

    GenServer.start_link(__MODULE__, metrics, name: __MODULE__)
  end

  @impl true
  def init(metrics) do
    Process.flag(:trap_exit, true)
    groups = Enum.group_by(metrics, & &1.event_name)

    for {event, metrics} <- groups do
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &handle_event/4, metrics)
    end

    {:ok, Map.keys(groups)}
  end

  @impl true
  def terminate(_, events) do
    for event <- events do
      :telemetry.detach({__MODULE__, event, self()})
    end

    :ok
  end

  defp handle_event([:bitfeels | _] = event_name, measurements, metadata, _metrics) do
    Bitfeels.Metrics.handle_event(event_name, measurements, metadata)
  end

  defp handle_event(_event_name, _measurements, _metadata, _metrics) do
    :ok
  end
end

