# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

# secret_key_base =
#   System.get_env("SECRET_KEY_BASE") ||
#     raise """
#     environment variable SECRET_KEY_BASE is missing.
#     You can generate one by calling: mix phx.gen.secret
#     """

config :sen_tweet, SenTweetWeb.Endpoint,
  http: [port: 4000],
  # TODO: generate during image build process
  secret_key_base: "AOWOel/9vWG2mEal/ToHHQleyRXWae/mn8Yp2wCPdj8GZ1brz65OeucDxdhdMjoG"
