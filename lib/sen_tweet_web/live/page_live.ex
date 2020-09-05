defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.Plots

  @topic inspect(__MODULE__)

  @impl true
  def mount(params, session, socket) do
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(SenTweet.PubSub, @topic)

    daily_stats = SenTweet.Bitfeels.Stats.Data.daily_stats()
    %{~D[2020-09-04] => last_day} = daily_stats

    daily_histogram = last_day[:extended_tweet][:tweets][:histogram]
    daily_svg = Plots.create(daily_histogram)

    hourly_stats = SenTweet.Bitfeels.Stats.Data.hourly_stats()
    %{22 => last_hour} = hourly_stats

    hourly_svg = hourly_svg(last_hour)

    {:ok, assign(socket, daily_svg: daily_svg, hourly_svg: hourly_svg,
      daily_type: "text", daily_weight: "tweets",
      hourly_type: "text", hourly_weight: "tweets")}
  end

  def is_selected(name, type, weight) do
    case String.split(name, "_") do
      [_, ^type] -> "button is-danger"
      [_, ^weight] -> "button is-danger"
      _ -> "button is-dark is-outlined"
    end
  end

  @impl true
  def handle_event("daily_text", _params, socket) do
    {:noreply, assign(socket, daily_type: "text")}
  end

  def handle_event(event, params, socket) do
    IO.inspect(event, label: "event")
    IO.inspect(params, label: "params")
    IO.inspect(socket, label: "socket")
    IO.inspect(Map.keys(socket), label: "socket keyszzz")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:bitfeels, last_hour}, socket) do
    hourly_svg = hourly_svg(last_hour)

    {:noreply, assign(socket, hourly_svg: hourly_svg)}
  end

  defp hourly_svg(last_hour) do
    hourly_histogram = last_hour[:extended_tweet][:tweets][:histogram]
    hourly_svg = Plots.create(hourly_histogram)
  end
end
