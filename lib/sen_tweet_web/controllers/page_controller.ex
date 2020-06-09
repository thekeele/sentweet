defmodule SenTweetWeb.PageController do
  use SenTweetWeb, :controller
  # import SenTweet.Bitfeels
  def index(conn, _params) do
    render(conn, "index.html")
  end

  def stream_admin(conn, _params) do
    streams = Bitfeels.all_streams()
    render(conn, "stream-admin.html", streams: streams)
  end
end
