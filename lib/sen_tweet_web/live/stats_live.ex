defmodule SenTweetWeb.StatsLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.StreamStats

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "hourly:stats")
    end

    stream = %{user: "bitfeels", track: "bitcoin"}
    filter = %{type: "text", weight: "tweets"}
    stream_stats = StreamStats.get(:hourly, stream, filter)

    assigns = [
      stream: stream_stats.stream,
      hourly: %{
        current_hour: stream_stats.current,
        stats: stream_stats.stats,
        svg: stream_stats.svg,
        filter: stream_stats.filter
      }
    ]

    {:ok, assign(socket, assigns)}
  end

  ###
  # Event Callbacks
  ###

  @impl true
  def handle_event("hourly_" <> event, _params, socket) do
    hourly = StreamStats.update(socket.assigns, event)

    {:noreply, assign(socket, hourly: hourly)}
  end

  ###
  # Broadcast Callbacks
  ###

  @impl true
  def handle_info({"hourly:stats", current_hour, last_hour_stats}, socket) do
    hourly = StreamStats.update(socket.assigns, current_hour, last_hour_stats)

    {:noreply, assign(socket, hourly: hourly)}
  end

  ###
  # View Helpers
  ###
  defp get_weight(data, weight, key) do
    tweet_type = StreamStats.to_tweet_type(data.filter.type)

    case data.stats[tweet_type][weight][key] do
      nil -> 0
      value when is_float(value) -> Float.round(value, 2)
      value -> value
    end
  end

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "is-focused"
      [_, ^weight] -> "is-focused"
      _ -> ""
    end
  end
end
