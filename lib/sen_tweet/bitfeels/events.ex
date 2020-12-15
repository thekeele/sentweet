defmodule SenTweet.Bitfeels.Events do
  @moduledoc """
  Handle incoming events emitted from the bitfeels application
  """
  alias SenTweet.Bitfeels.{HourlyStats, Stats}

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    {_current_hour, stats} = HourlyStats.get(metadata)

    stats
    |> Stats.update_score(measurements, metadata)
    |> HourlyStats.put(metadata)
    |> broadcast_stats(metadata)
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end

  defp broadcast_stats({current_hour, last_hour_stats}, metadata) do
    message = {metadata, "hourly", current_hour, last_hour_stats}

    Phoenix.PubSub.broadcast(SenTweet.PubSub, "stats:hourly", message)
  end
end
