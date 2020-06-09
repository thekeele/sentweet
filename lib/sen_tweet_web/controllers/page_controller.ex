defmodule SenTweetWeb.PageController do
  use SenTweetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def stream_admin(conn, _params) do
    render(conn, "stream-admin.html", streams: [1,2,3,4,5])
  end
end
