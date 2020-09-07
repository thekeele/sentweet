defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.{DailyStats, HourlyStats, Plots, Stats}

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
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "daily:stats")
    end

    stream = %{user: "bitfeels", track: "bitcoin"}
    filter = %{type: "text", weight: "tweets"}

    daily_svg = daily_svg(stream, filter)
    hourly_svg = hourly_svg(stream, filter)

    assigns = [
      stream: stream,
      daily_svg: daily_svg,
      daily_type: filter.type,
      daily_weight: filter.weight,
      hourly_svg: hourly_svg,
      hourly_type: filter.type,
      hourly_weight: filter.weight
    ]

    {:ok, assign(socket, assigns)}
  end

  ###
  # Event Callbacks
  ###

  @impl true
  def handle_event("daily_" <> event, _params, socket) when event in @type_events do
    filter = %{type: event, weight: socket.assigns.daily_weight}
    daily_svg = daily_svg(socket.stream, filter)

    {:noreply, assign(socket, daily_svg: daily_svg, daily_type: event)}
  end

  def handle_event("daily_" <> event, _params, socket) when event in @weight_events do
    filter = %{type: socket.assigns.daily_type, weight: event}
    daily_svg = daily_svg(socket.stream, filter)

    {:noreply, assign(socket, daily_svg: daily_svg, daily_weight: event)}
  end

  def handle_event("hourly_" <> event, _params, socket) when event in @type_events do
    filter = %{type: event, weight: socket.assigns.hourly_weight}
    hourly_svg = hourly_svg(socket.stream, filter)

    {:noreply, assign(socket, hourly_svg: hourly_svg, hourly_type: event)}
  end

  def handle_event("hourly_" <> event, _params, socket) when event in @weight_events do
    filter = %{type: socket.assigns.hourly_type, weight: event}
    hourly_svg = hourly_svg(socket.stream, filter)

    {:noreply, assign(socket, hourly_svg: hourly_svg, hourly_weight: event)}
  end

  ###
  # Broadcast Callbacks
  ###

  @impl true
  def handle_info({"hourly:stats", last_hour}, socket) do
    filter = %{type: socket.assigns.hourly_type, weight: socket.assigns.hourly_weight}
    hourly_svg = create_svg(last_hour, filter)

    {:noreply, assign(socket, hourly_svg: hourly_svg)}
  end

  def handle_info({"daily:stats", last_day}, socket) do
    filter = %{type: socket.assigns.daily_type, weight: socket.assigns.daily_weight}
    daily_svg = create_svg(last_day, filter)

    {:noreply, assign(socket, daily_svg: daily_svg)}
  end

  ###
  # Helpers
  ###

  defp daily_svg(stream, filter) do
    stream |> DailyStats.get() |> create_svg(filter)
  end

  defp hourly_svg(stream, filter) do
    stream |> HourlyStats.get() |> create_svg(filter)
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

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "is-focused"
      [_, ^weight] -> "is-focused"
      _ -> ""
    end
  end
end
