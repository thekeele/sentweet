defmodule SenTweet.BitfeelsBot.Auth do
  @moduledoc """
  Authentication and Authorization for the BitfeelsBot on Twitter

  Guides
  https://developer.twitter.com/en/docs/basics/authentication/oauth-1-0a/obtaining-user-access-tokens
  https://developer.twitter.com/en/docs/basics/authentication/oauth-1-0a/pin-based-oauth

  3 legged OAuth with PIN steps
  1. https://developer.twitter.com/en/docs/basics/authentication/api-reference/request_token
    Use oob for oauth_callback for out of band requests, no browser
  2. https://developer.twitter.com/en/docs/basics/authentication/api-reference/authorize
    GET https://api.twitter.com/oauth/authorize?oauth_token=OAUTH_TOKEN
    with oauth_token from step 1
    Authorize the app and get the pin
  3. https://developer.twitter.com/en/docs/basics/authentication/api-reference/access_token
    Use oauth_token from step 1
    Use pin from step 2

  FAQ
  https://developer.twitter.com/en/docs/basics/apps/faq
  """

  def auth_header(method, url, params) do
    method |> sign(url, params) |> OAuther.header()
  end

  defp sign(method, url, params) do
    OAuther.sign(method, url, params, credentials())
  end

  defp credentials() do
    OAuther.credentials(
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      token: System.get_env("BITFEELS_BOT_ACCESS_TOKEN"),
      token_secret: System.get_env("BITFEELS_BOT_TOKEN_SECRET")
    )
  end

  # 3 legged OAUTH step 1
  def request_token(oauth_callback \\ "oob") do
    method = "post"
    url = "https://api.twitter.com/oauth/request_token"
    params = [{"oauth_callback", oauth_callback}]
    {header, req_params} = auth_header(method, url, params)

    do_request(url, header, req_params)
  end

  # 3 legged OAUTH step 3
  def access_token(oauth_token, pin) when is_binary(pin) do
    method = "post"
    url = "https://api.twitter.com/oauth/access_token"
    params = [{"oauth_token", oauth_token}, {"oauth_verifier", pin}]
    {header, req_params} = auth_header(method, url, params)

    do_request(url, header, req_params)
  end

  defp do_request(url, header, req_params) do
    case :hackney.post(url, [header], {:form, req_params}, [:with_body]) do
      {:ok, _status, _headers, body} ->
        {:ok, URI.decode_query(body)}

      error ->
        error
    end
  end
end
