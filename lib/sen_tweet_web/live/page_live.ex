defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.Plots

  @topic inspect(__MODULE__)

  @impl true
  def mount(params, session, socket) do
    IO.inspect(params, label: "params")
    IO.inspect(session, label: "session")
    IO.inspect(socket, label: "socket")
    IO.inspect(connected?(socket), label: "connected")

    if connected?(socket), do: Phoenix.PubSub.subscribe(SenTweet.PubSub, @topic) |> IO.inspect(label: "subscribed")

    svg = Plots.create()

    {:ok, assign(socket, svg: svg)}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect(event, label: "event")
    IO.inspect(params, label: "params")
    IO.inspect(socket, label: "socket")
  end

  @impl true
  def handle_info({:bitfeels, stats}, socket) do
    IO.puts "bitfeels stats"
    IO.inspect(socket, label: "socket")

    svg = Plots.create(stats)

    {:noreply, assign(socket, svg: svg)}
  end
end
