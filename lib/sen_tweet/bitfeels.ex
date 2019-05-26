defmodule SenTweet.Bitfeels do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_info({:tweet, data}, opts) do
    IO.inspect(data, label: "#{__MODULE__} sunk data")

    {:noreply, opts}
  end
end
