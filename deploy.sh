#!/bin/bash

set -e

git stash
git pull origin master

mix local.rebar --force
mix local.hex --force
mix deps.get --only prod
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite

echo "Restarting Release"
_build/prod/rel/sen_tweet/bin/sen_tweet restart

echo "Release Version"
_build/prod/rel/sen_tweet/bin/sen_tweet version

echo "Release PID"
_build/prod/rel/sen_tweet/bin/sen_tweet pid

git stash pop
