defmodule SenTweetWeb.PageLive do
  @moduledoc false

  use SenTweetWeb, :live_view

  alias SenTweet.Bitfeels.Plots

  @impl true
  def mount(params, session, socket) do
    IO.inspect(params, label: "params")
    IO.inspect(session, label: "session")
    IO.inspect(socket, label: "socket")

    svg = Plots.create()

    {:ok, assign(socket, svg: svg) |> IO.inspect(label: "assign")}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect(event, label: "event")
    IO.inspect(params, label: "params")
    IO.inspect(socket, label: "socket")
  end
end
