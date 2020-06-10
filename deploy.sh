#!/bin/bash

# bail if any command fails
set -e

# pull sentweet master
git pull origin master

# build latest release
mix local.rebar --force
mix local.hex --force
mix deps.get --only prod
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite

echo "Starting up new release"

echo "Stop Release"
_build/prod/rel/sen_tweet/bin/sen_tweet stop

echo "Start Release as Daemon"
_build/prod/rel/sen_tweet/bin/sen_tweet daemon_iex

echo "Release Version: $(_build/prod/rel/sen_tweet/bin/sen_tweet version)"

echo "Release PID: $(_build/prod/rel/sen_tweet/bin/sen_tweet pid)"
