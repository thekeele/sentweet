defmodule SenTweet.StreamStats do

  @type_events ["text", "extended", "retweeted", "quoted"]
  @weight_events ["tweets", "likes", "retweets"]
  @event_type_tweet_type %{
    "text" => :text,
    "extended" => :extended_tweet,
    "retweeted" => :retweeted_status,
    "quoted" => :quoted_status
  }

  def get(:hourly, stream, filter) do
    {current, stats} = HourlyStats.get(stream)

    svg = create_svg(stats, filter)

    %{
      interval: :hourly,
      stream: stream.track,
      filter: filter,
      stats: stats,
      current: current,
      svg: svg
    }
  end

  def update(%{hourly: hourly}, event) when event in @type_events do
    hourly
    |> add_event([:filter, :type], event)
    |> update_svg()
  end

  def update(%{hourly: hourly}, event) when event in @weight_events do
    hourly
    |> add_event([:filter, :weight], event)
    |> update_svg()
  end

  def update(%{hourly: hourly}, current_hour, last_hour_stats) do
    hourly
    |> add_event([:current_hour], current_hour)
    |> add_event([:stats], last_hour_stats)
    |> update_svg()
  end

  def to_tweet_type(event) when is_binary(event) do
    @event_type_tweet_type[event]
  end

  ###
  # Helpers
  ###

  defp add_event(data, keys, event) do
    put_in(data, keys, event)
  end

  defp update_svg(data) do
    Map.put(data, :svg, create_svg(data.stats, data.filter))
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
end
