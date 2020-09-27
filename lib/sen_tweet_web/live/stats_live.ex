defmodule SenTweetWeb.StatsLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.{HourlyStats, Plots, Stats}

  @type_events ["text", "extended", "retweeted", "quoted"]
  @weight_events ["tweets", "likes", "retweets"]
  @event_type_tweet_type %{
    "text" => :text,
    "extended" => :extended_tweet,
    "retweeted" => :retweeted_status,
    "quoted" => :quoted_status
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "hourly:stats")
    end

    stream = %{user: "bitfeels", track: "bitcoin"}
    filter = %{type: "text", weight: "tweets"}

    {current_hour, hourly_stats} = HourlyStats.get(stream)
    hourly_svg = create_svg(hourly_stats, filter)

    assigns = [
      stream: stream,
      hourly: %{
        current_hour: current_hour,
        stats: hourly_stats,
        svg: hourly_svg,
        filter: filter
      }
    ]

    {:ok, assign(socket, assigns)}
  end

  ###
  # Event Callbacks
  ###

  @impl true
  def handle_event("hourly_" <> event, _params, socket) when event in @type_events do
    hourly = socket.assigns.hourly |> add_event([:filter, :type], event) |> update_svg()

    {:noreply, assign(socket, hourly: hourly)}
  end

  def handle_event("hourly_" <> event, _params, socket) when event in @weight_events do
    hourly = socket.assigns.hourly |> add_event([:filter, :weight], event) |> update_svg()

    {:noreply, assign(socket, hourly: hourly)}
  end

  ###
  # Broadcast Callbacks
  ###

  @impl true
  def handle_info({"hourly:stats", current_hour, last_hour_stats}, socket) do
    hourly =
      socket.assigns.hourly
      |> add_event([:current_hour], current_hour)
      |> add_event([:stats], last_hour_stats)
      |> update_svg()

    {:noreply, assign(socket, hourly: hourly)}
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

  defp get_histogram(stats, %{type: type, weight: weight}) do
    tweet_type = @event_type_tweet_type[type]
    weight_factor = String.to_existing_atom(weight)

    stats[tweet_type][weight_factor][:histogram]
  end

  defp get_weight(data, weight, key) do
    tweet_type = @event_type_tweet_type[data.filter.type]

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
