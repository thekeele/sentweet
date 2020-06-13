defmodule SenTweetWeb.StreamController do
  use SenTweetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", streams: Bitfeels.all_streams())
  end
end
