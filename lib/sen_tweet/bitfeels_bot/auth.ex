defmodule SenTweet.BitfeelsBot.Auth do
  @moduledoc """
  Authentication for the @bitfeelsbot on Twitter
  """

  def auth_header(method, url, params) do
    method |> sign(url, params) |> OAuther.header()
  end

  defp sign(method, url, params) do
    OAuther.sign(method, url, params, credentials())
  end

  defp credentials do
    OAuther.credentials(
      consumer_key: System.get_env("BITFEELS_BOT_API_KEY"),
      consumer_secret: System.get_env("BITFEELS_BOT_API_SECRET"),
      token: System.get_env("BITFEELS_BOT_ACCESS_TOKEN"),
      token_secret: System.get_env("BITFEELS_BOT_TOKEN_SECRET")
    )
  end
end
