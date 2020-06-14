defmodule SenTweetWeb.StreamController do
  use SenTweetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", streams: Bitfeels.all_streams())
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => user, "track" => track, "filter_level" => filter_level}) do
    Bitfeels.twitter_stream(user, track, filter_level)
    redirect(conn, to: "/admin/streams")
  end

  def delete(conn, %{"id" => id}) do
    [user, track] = String.split(id, "_")
    Bitfeels.stop_stream(user, track)
    redirect(conn, to: "/admin/streams")
  end
end
