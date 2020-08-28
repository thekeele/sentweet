defmodule SenTweet.Bitfeels.Events do
  alias SenTweet.Bitfeels.{Stats, HourlyStats}

  def handle_event([:bitfeels, :pipeline, :sentiment], %{score: score} = measurements, metadata)
      when is_float(score) do
    metadata
    |> HourlyStats.get()
    |> Stats.update_score(measurements, metadata)
    |> Stats.update_metadata(measurements, metadata)
    |> HourlyStats.put(metadata)
  end

  def handle_event(_event, _measurements, _metadata) do
    %{}
  end
end
