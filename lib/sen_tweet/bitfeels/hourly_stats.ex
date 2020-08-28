defmodule SenTweet.Bitfeels.HourlyStats do
  @moduledoc """
  Process that manages hourly statistics for bitfeels
  """
  use GenServer

  alias SenTweet.Bitfeels.Stats

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def get(metadata) do
    GenServer.call(__MODULE__, {:get, metadata})
  end

  def put(stats, metadata) do
    GenServer.call(__MODULE__, {:put, stats, metadata})
  end

  # Server

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, metadata}, _from, state) do
    stream_key = stream_key(metadata)
    current_hour = current_hour()
    hourly_stats = get_hourly_stats(state[stream_key], current_hour)

    {:reply, hourly_stats[current_hour], %{stream_key => hourly_stats}}
  end

  def handle_call({:put, stats, metadata}, _from, state) do
    stream_key = stream_key(metadata)
    current_hour = current_hour()

    hourly_stats =
      state[stream_key] |> get_hourly_stats(current_hour) |> Map.put(current_hour, stats)

    {:reply, hourly_stats[current_hour], %{stream_key => hourly_stats}}
  end

  # Helper functions

  defp stream_key(%{user: user, track: track}) do
    "#{user}_#{track}"
  end

  defp current_hour do
    time = Time.utc_now()
    time.hour
  end

  defp get_hourly_stats(nil, current_hour), do: %{current_hour => Stats.create()}

  defp get_hourly_stats(hourly_stats, current_hour) do
    case hourly_stats do
      %{^current_hour => _} -> hourly_stats
      _new_hour -> Map.put(hourly_stats, current_hour, Stats.create())
    end
  end
end
