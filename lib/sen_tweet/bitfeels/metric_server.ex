defmodule SenTweet.Bitfeels.MetricServer do
  @moduledoc """
  Manage and store the state of Bitfeels Metrics
  """
  use GenServer

  alias SenTweet.Bitfeels.Metrics

  # save to file every 5 minutes
  @save_interval 5 * 60 * 1000

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init_metrics(metadata) do
    GenServer.call(__MODULE__, {:init_metrics, metadata}, 10_000)
  end

  def get_metrics(metadata) do
    GenServer.call(__MODULE__, {:get_metrics, metadata})
  end

  def update_metrics(metrics, metadata) do
    GenServer.call(__MODULE__, {:update_metrics, metrics, metadata})
  end

  # Server

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:init_metrics, %{user: user, track: track}}, _from, state) do
    stream_key = "#{user}_#{track}"

    state =
      if Map.has_key?(state, stream_key) do
        state
      else
        {:ok, tab} = :dets.open_file('data/#{stream_key}', [{:type, :set}])

        schedule_metrics_saving(stream_key)

        case :dets.lookup(tab, :metrics) do
          [metrics: metrics] ->
            Map.put(state, stream_key, metrics)

          [] ->
            Map.put(state, stream_key, Metrics.create_metrics())
        end
      end

    {:reply, :ok, state}
  end

  def handle_call({:get_metrics, %{user: user, track: track}}, _from, state) do
    stream_key = "#{user}_#{track}"

    metrics = Map.get(state, stream_key)

    {:reply, metrics, state}
  end

  def handle_call({:update_metrics, metrics, %{user: user, track: track}}, _from, state) do
    stream_key = "#{user}_#{track}"

    state = Map.put(state, stream_key, metrics)

    {:reply, metrics, state}
  end

  def handle_info({:save_metrics, stream_key}, state) do
    metrics = Map.get(state, stream_key)

    :dets.insert('data/#{stream_key}', {:metrics, metrics})

    schedule_metrics_saving(stream_key)

    {:noreply, state}
  end

  # Helpers

  defp schedule_metrics_saving(stream_key) do
    Process.send_after(self(), {:save_metrics, stream_key}, @save_interval)
  end
end
