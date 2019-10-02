defmodule SenTweetWeb.MetricChannel do
  use Phoenix.Channel

  def join("room:metrics", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _room, _params, _socket) do
    {:error, %{reason: "not available"}}
  end

  def broadcast_metrics(metrics) when is_map(metrics) do
    SenTweetWeb.Endpoint.broadcast("room:metrics", "update_metrics", metrics)
  end
end
