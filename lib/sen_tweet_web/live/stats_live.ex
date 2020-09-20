defmodule SenTweetWeb.StatsLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.{DailyStats, HourlyStats, Plots, Stats}

  @event_type_tweet_type %{
    "text" => :text,
    "extended" => :extended_tweet,
    "retweeted" => :retweeted_status,
    "quoted" => :quoted_status
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "stats:hourly")
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "stats:daily")
    end

    streams =
      Bitfeels.all_streams()
      |> Enum.into(%{}, fn stream -> {stream.track, mount_stats(stream)} end)

    {:ok, assign(socket, streams: streams)}
  end

  defp mount_stats(stream) do
    filter = %{"type" => "text", "weight" => "tweets"}

    {current_hour, hourly_stats} = HourlyStats.get(stream)
    hourly_svg = create_svg(hourly_stats, filter)

    {current_day, daily_stats} = DailyStats.get(stream)
    daily_svg = create_svg(daily_stats, filter)

    %{
      "hourly" => %{
        current: current_hour,
        stats: hourly_stats,
        svg: hourly_svg,
        filter: filter
      },
      "daily" => %{
        current: current_day,
        stats: daily_stats,
        svg: daily_svg,
        filter: filter
      }
    }
  end

  ###
  # Event Callbacks
  ###

  @impl true
  def handle_event(event, %{"stream" => stream, "interval" => interval, "filter" => kind}, socket) do
    streams = socket.assigns.streams
    data = streams[stream][interval] |> add_event([:filter, kind], event) |> update_svg()

    {:noreply, assign(socket, streams: put_in(streams, [stream, interval], data))}
  end

  ###
  # Broadcast Callbacks
  ###

  @impl true
  def handle_info({stream, interval, current, stats}, socket) do
    streams = socket.assigns.streams

    data =
      streams[stream.track][interval]
      |> add_event([:current], current)
      |> add_event([:stats], stats)
      |> update_svg()

    {:noreply, assign(socket, streams: put_in(streams, [stream.track, interval], data))}
  end

  ###
  # Helpers
  ###

  defp add_event(data, keys, event) do
    put_in(data, keys, event)
  end

  defp update_svg(data) do
    Map.put(data, :svg, create_svg(data.stats, data.filter))
  end

  defp create_svg(stats, filter) do
    stats |> get_histogram(filter) |> Plots.create()
  end

  defp get_histogram([], filter) do
    get_histogram(Stats.create(), filter)
  end

  defp get_histogram(stats, %{"type" => type, "weight" => weight}) do
    tweet_type = @event_type_tweet_type[type]
    weight_factor = String.to_existing_atom(weight)

    stats[tweet_type][weight_factor][:histogram]
  end

  defp get_weight(data, weight, key) do
    tweet_type = @event_type_tweet_type[data.filter["type"]]

    data.stats[tweet_type][weight][key] || 0
  end

  defp round_up(value) when is_float(value) do
    Float.round(value, 2)
  end

  defp round_up(_), do: 0

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "is-focused"
      [_, ^weight] -> "is-focused"
      _ -> ""
    end
  end
end
