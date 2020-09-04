defmodule SenTweet.Bitfeels.HourlyStats do
  @moduledoc """
  Process that manages hourly statistics for bitfeels
  """
  use GenServer

  alias SenTweet.Bitfeels.{DailyStats, Stats}
  alias SenTweet.BitfeelsBot

  # hour 0 in utc time, hour 8pm in est
  @publish_hour 0

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
      state[stream_key]
      |> get_hourly_stats(current_hour)
      |> put_hourly_stats(current_hour, stats, metadata)

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

  defp put_hourly_stats(hourly_stats, current_hour, stats, metadata) do
    if publish?(hourly_stats, current_hour) do
      publish_stats(hourly_stats, metadata)

      Map.put(%{}, current_hour, stats)
    else
      Map.put(hourly_stats, current_hour, stats)
    end
  end

  defp publish?(hourly_stats, current_hour) do
    current_hour == @publish_hour and Enum.count(hourly_stats) > 1
  end

  defp publish_stats(hourly_stats, metadata) do
    stats_to_publish = Stats.aggregate(hourly_stats)

    DailyStats.put(stats_to_publish, metadata)

    BitfeelsBot.tweet(stats_to_publish, metadata)
  end
end
