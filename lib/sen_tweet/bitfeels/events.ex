defmodule SenTweet.Bitfeels.Events do
  @moduledoc """
  Handle incoming events emitted from the bitfeels application
  """
  alias SenTweet.Bitfeels.{HourlyStats, Stats}

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    metadata
    |> HourlyStats.get()
    |> Stats.update_score(measurements, metadata)
    |> HourlyStats.put(metadata)
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end
end
