defmodule SenTweet.BitfeelsBot.Twitter do
  @moduledoc """
  Functions for interacting with the Twitter API

  tweet - POST statuses/update
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-update

  get_tweet - POST statuses/lookup
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-lookup

  delete_tweet - POST statuses/destroy/:id
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-destroy-id
  """

  alias SenTweet.BitfeelsBot.Auth

  def tweet() do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/update.json"
    params = [{"status", "hello twitter 🤖"}]
    {header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, header, req_params)
  end

  def get_tweet(tweet_id) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/lookup.json"
    params = [{"id", tweet_id}]
    {header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, header, req_params)
  end

  def delete_tweet(tweet_id) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/destroy/#{tweet_id}.json"
    params = []
    {header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, header, req_params)
  end

  defp do_request(url, header, req_params) do
    case :hackney.post(url, [header], {:form, req_params}, [:with_body]) do
      {:ok, _status, _headers, body} ->
        {:ok, Jason.decode!(body)}

      error ->
        error
    end
  end
end
