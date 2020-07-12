#!/bin/bash

set -e

git pull origin master

mix local.rebar --force
mix local.hex --force
mix deps.get --only prod
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite

_build/prod/rel/sen_tweet/bin/sen_tweet restart

# echo "Release PID"
# _build/prod/rel/sen_tweet/bin/sen_tweet pid

# echo "Restarting Release"
# _build/prod/rel/sen_tweet/bin/sen_tweet stop
# _build/prod/rel/sen_tweet/bin/sen_tweet daemon_iex

# echo "Release Version"
# _build/prod/rel/sen_tweet/bin/sen_tweet version

# echo "Release PID"
# _build/prod/rel/sen_tweet/bin/sen_tweet pid
