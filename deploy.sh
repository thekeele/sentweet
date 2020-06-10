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

# check if release pid is running
# restart if pid, otherwise start release as daemon
echo "Check PID"
_build/prod/rel/sen_tweet/bin/sen_tweet pid
if [ $? -eq 0 ]
then
  echo "Restarting Release"
  _build/prod/rel/sen_tweet/bin/sen_tweet stop
  sleep 5s
  _build/prod/rel/sen_tweet/bin/sen_tweet daemon_iex
else
  echo "Starting Release as Daemon"
  _build/prod/rel/sen_tweet/bin/sen_tweet daemon_iex
fi

echo "Release PID: $(_build/prod/rel/sen_tweet/bin/sen_tweet pid)"
