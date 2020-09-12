defmodule SenTweet.Bitfeels.DailyStats do
  @moduledoc """
  Process that manages daily statistics for bitfeels
  """
  use GenServer

  @number_days_to_store 30

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets daily stats with dates
  Accepts a start_date and end_date filter to all a range of data

  Examples

      iex> metadata = %{user: "bitfeels", track: "bitcoin"}
      %{track: "bitcoin", user: "bitfeels"}

      iex> SenTweet.Bitfeels.DailyStats.all(metadata)
      %{~D[2020-08-29] => %{score: 0.5}}

      iex> filter = %{start_date: Date.add(Date.utc_today(), -5), end_date: Date.utc_today()}
      %{end_date: ~D[2020-09-03], start_date: ~D[2020-08-29]}

      iex> SenTweet.Bitfeels.DailyStats.all(filter, metadata)
      %{~D[2020-08-29] => %{score: 0.5}, ~D[2020-08-30] => %{score: 0.75}}
  """
  def all(filter, metadata) do
    GenServer.call(__MODULE__, {:all, filter, metadata})
  end

  @doc """
  Get the stats for the current day for a given stream

  Examples

      iex> metadata = %{user: "bitfeels", track: "bitcoin"}
      %{track: "bitcoin", user: "bitfeels"}

      iex> SenTweet.Bitfeels.DailyStats.get(metadata)
      %{score: 0.5}
  """
  def get(metadata) do
    GenServer.call(__MODULE__, {:get, metadata})
  end

  @doc """
  Add stats map to current day for the given stream

  Examples

      iex> stats = %{score: 0.5}
      %{score: 0.5}

      iex> metadata = %{user: "bitfeels", track: "bitcoin"}
      %{track: "bitcoin", user: "bitfeels"}

      iex> SenTweet.Bitfeels.DailyStats.put(stats, metadata)
      :ok
  """
  def put(stats, metadata) do
    GenServer.cast(__MODULE__, {:put, stats, metadata})
  end

  # Server

  def init(_opts) do
    {:ok, tab} = :dets.open_file('data/daily_stats', [{:type, :set}])

    {:ok, %{tab: tab}}
  end

  def handle_call({:all, filter, metadata}, _from, state) do
    stream_key = stream_key(metadata)

    daily_stats =
      state.tab
      |> get_days(stream_key)
      |> filter_days(filter)
      |> Enum.into(%{})

    {:reply, daily_stats, state}
  end

  def handle_call({:get, metadata}, _from, state) do
    stream_key = stream_key(metadata)

    stats =
      state.tab
      |> get_days(stream_key)
      |> filter_days()

    {:reply, {Date.utc_today(), stats}, state}
  end

  def handle_cast({:put, stats, metadata}, state) do
    stream_key = stream_key(metadata)
    current_day = Date.utc_today()

    state.tab
    |> get_days(stream_key)
    |> Map.put(current_day, stats)
    |> put_days(state.tab, stream_key)

    {:noreply, state}
  end

  # Helper functions

  defp stream_key(%{user: user, track: track}) do
    "#{user}_#{track}"
  end

  defp get_days(tab, stream_key) do
    case :dets.lookup(tab, stream_key) do
      [{_stream_key, days}] -> days
      [] -> %{}
    end
  end

  defp filter_days(days, filter \\ %{}) do
    Enum.filter(days, fn {day, _stats} -> in_data_range?(day, filter) end)
  end

  defp in_data_range?(day, %{start_date: start_date, end_date: end_date}) do
    day in Date.range(start_date, end_date)
  end

  defp in_data_range?(day, _filter) do
    day in Date.range(Date.utc_today(), Date.utc_today())
  end

  defp put_days(days, tab, stream_key) do
    :dets.insert(tab, {stream_key, trim_day(days)})
  end

  defp trim_day(days) do
    if Enum.count(days) > @number_days_to_store do
      Map.delete(days, oldest_day(days))
    else
      days
    end
  end

  defp oldest_day(days) do
    days |> Map.keys() |> Enum.sort({:asc, Date}) |> List.first()
  end
end
