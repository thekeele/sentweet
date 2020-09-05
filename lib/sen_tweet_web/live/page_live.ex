defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.{DailyStats, HourlyStats, Plots}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "hourly:stats")
      Phoenix.PubSub.subscribe(SenTweet.PubSub, "daily:stats")
    end

    metadata = %{user: "bitfeels", track: "bitcoin"}

    daily_svg =
      metadata
      |> DailyStats.get()
      |> get_histogram()
      |> Plots.create()

    hourly_svg =
      metadata
      |> HourlyStats.get()
      |> get_histogram()
      |> Plots.create()

    assigns = [
      daily_svg: daily_svg,
      daily_type: "text",
      daily_weight: "tweets",
      hourly_svg: hourly_svg,
      hourly_type: "text",
      hourly_weight: "tweets"
    ]

    {:ok, assign(socket, assigns)}
  end

  ###
  # Callbacks
  ###

  @impl true
  def handle_event("daily_text", _params, socket) do
    {:noreply, assign(socket, daily_type: "text")}
  end

  def handle_event(event, params, socket) do
    IO.inspect(event, label: "event")
    IO.inspect(params, label: "params")
    IO.inspect(socket, label: "socket")
    {:noreply, socket}
  end

  @impl true
  def handle_info({"hourly:stats", last_hour}, socket) do
    hourly_svg =
      last_hour
      |> get_histogram()
      |> Plots.create()

    {:noreply, assign(socket, hourly_svg: hourly_svg)}
  end

  def handle_info({"daily:stats", last_day}, socket) do
    daily_svg =
      last_day
      |> get_histogram()
      |> Plots.create()

    {:noreply, assign(socket, daily_svg: daily_svg)}
  end

  ###
  # Helpers
  ###
  defp get_histogram(stats), do: stats[:extended_tweet][:tweets][:histogram]

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "button is-danger"
      [_, ^weight] -> "button is-danger"
      _ -> "button is-dark is-outlined"
    end
  end
end
