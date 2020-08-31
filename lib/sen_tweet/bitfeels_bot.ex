defmodule SenTweet.BitfeelsBot do
  @moduledoc false

  require Logger

  def tweet(stats, metadata) do
    Logger.info("""
    #{__MODULE__}.tweet/2
    stats: inspect(stats)
    metadata: inspect(metadata)
    """)

    :ok
  end
end
