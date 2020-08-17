defmodule SenTweet.BitfeelsBot.Twitter do
  @moduledoc """
  Functions for interacting with the Twitter API

  tweet - POST statuses/update
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-update

  get_tweet - POST statuses/lookup
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-lookup

  delete_tweet - POST statuses/destroy/:id
  https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/post-statuses-destroy-id

  upload_image - POST media/upload (Image Size 5MB MAX, JPEG, JPG, PNG)
  https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/api-reference/post-media-upload
  https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/uploading-media/media-best-practices
  """

  alias SenTweet.BitfeelsBot.Auth

  def tweet(tweet_text) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/update.json"
    params = [{"status", tweet_text}]
    {auth_header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, [auth_header], req_params)
  end

  def tweet_with_image(tweet_text, media_id) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/update.json"
    params = [{"status", tweet_text}, {"media_ids", "#{media_id}"}]
    {auth_header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, [auth_header], req_params)
  end

  def get_tweet(tweet_id) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/lookup.json"
    params = [{"id", tweet_id}]
    {auth_header, req_params} = Auth.auth_header(method, url, params)

    do_request(url, [auth_header], req_params)
  end

  def delete_tweet(tweet_id) do
    method = "post"
    url = "https://api.twitter.com/1.1/statuses/destroy/#{tweet_id}.json"
    {auth_header, req_params} = Auth.auth_header(method, url, [])

    do_request(url, [auth_header], req_params)
  end

  def upload_image(image_name) do
    method = "post"
    url = "https://upload.twitter.com/1.1/media/upload.json"

    image_path = "images/" <> image_name
    encoded_image = image_path |> File.read!() |> Base.encode64()

    params = [{"media_data", encoded_image}]
    {auth_header, req_params} = Auth.auth_header(method, url, params)
    headers = [auth_header, {"Content-Type", "application/x-www-form-urlencoded"}]

    do_request(url, headers, req_params)
  end

  defp do_request(url, headers, req_params) do
    case :hackney.post(url, headers, {:form, req_params}, [:with_body]) do
      {:ok, _status, _headers, body} ->
        {:ok, Jason.decode!(body)}

      error ->
        error
    end
  end
end
