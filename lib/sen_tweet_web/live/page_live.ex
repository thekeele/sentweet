defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.{DailyStats, HourlyStats, Plots}

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

    metadata = %{user: "bitfeels", track: "bitcoin"}
    default_filter = %{type: "text", weight: "tweets"}

    daily_svg =
      metadata
      |> DailyStats.get()
      |> get_histogram(default_filter)
      |> Plots.create()

    hourly_svg =
      metadata
      |> HourlyStats.get()
      |> get_histogram(default_filter)
      |> Plots.create()

    assigns = [
      daily_svg: daily_svg,
      daily_type: default_filter.type,
      daily_weight: default_filter.weight,
      hourly_svg: hourly_svg,
      hourly_type: default_filter.type,
      hourly_weight: default_filter.weight
    ]

    {:ok, assign(socket, assigns)}
  end

  ###
  # Event Callbacks
  ###

  @impl true
  def handle_event("daily_" <> event, _params, socket) when event in @type_events do
    daily_svg =
      %{user: "bitfeels", track: "bitcoin"}
      |> DailyStats.get()
      |> get_histogram(%{type: event, weight: socket.assigns.daily_weight})
      |> Plots.create()

    {:noreply, assign(socket, daily_svg: daily_svg, daily_type: event)}
  end

  def handle_event("daily_" <> event, _params, socket) when event in @weight_events do
    daily_svg =
      %{user: "bitfeels", track: "bitcoin"}
      |> DailyStats.get()
      |> get_histogram(%{type: socket.assigns.daily_type, weight: event})
      |> Plots.create()

    {:noreply, assign(socket, daily_svg: daily_svg, daily_weight: event)}
  end

  def handle_event("hourly_" <> event, _params, socket) when event in @type_events do
    hourly_svg =
      %{user: "bitfeels", track: "bitcoin"}
      |> HourlyStats.get()
      |> get_histogram(%{type: event, weight: socket.assigns.hourly_weight})
      |> Plots.create()

    {:noreply, assign(socket, hourly_svg: hourly_svg, hourly_type: event)}
  end

  def handle_event("hourly_" <> event, _params, socket) when event in @weight_events do
    hourly_svg =
      %{user: "bitfeels", track: "bitcoin"}
      |> HourlyStats.get()
      |> get_histogram(%{type: socket.assigns.hourly_type, weight: event})
      |> Plots.create()

    {:noreply, assign(socket, hourly_svg: hourly_svg, hourly_weight: event)}
  end

  ###
  # Broadcast Callbacks
  ###

  @impl true
  def handle_info({"hourly:stats", last_hour}, socket) do
    assigns = socket.assigns

    hourly_svg =
      last_hour
      |> get_histogram(%{type: assigns.hourly_type, weight: assigns.hourly_weight})
      |> Plots.create()

    {:noreply, assign(socket, hourly_svg: hourly_svg)}
  end

  def handle_info({"daily:stats", last_day}, socket) do
    assigns = socket.assigns

    daily_svg =
      last_day
      |> get_histogram(%{type: assigns.daily_type, weight: assigns.daily_weight})
      |> Plots.create()

    {:noreply, assign(socket, daily_svg: daily_svg)}
  end

  ###
  # Helpers
  ###
  defp get_histogram(stats, %{type: type, weight: weight}) do
    tweet_type = @event_type_tweet_type[type]
    weight_factor = String.to_existing_atom(weight)

    stats[tweet_type][weight_factor][:histogram]
  end

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "button is-danger"
      [_, ^weight] -> "button is-danger"
      _ -> "button is-dark is-outlined"
    end
  end
end
