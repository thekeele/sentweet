#!/bin/bash

# bail if any command fails
trap 'exit' ERR

# pull sentweet master
git pull origin master

# build latest release
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite

# start release as daemon with iex attached
_build/prod/rel/sen_tweet/bin/sen_tweet daemon_iex
echo "Release PID: $(_build/prod/rel/sen_tweet/bin/sen_tweet pid)"
