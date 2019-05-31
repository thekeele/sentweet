TWITTER_CONSUMER_KEY ?= "$(echo $TWITTER_CONSUMER_KEY)"
TWITTER_ACCESS_TOKEN ?= "$(echo $TWITTER_ACCESS_TOKEN)"
TWITTER_CONSUMER_SECRET ?= "$(echo $TWITTER_CONSUMER_SECRET)"
TWITTER_TOKEN_SECRET ?= "$(echo $TWITTER_TOKEN_SECRET)"

install:
	mix deps.get
	mix compile

help:
	mix help

dev:
	mix phx.server

build:
	docker build \
	--build-arg TWITTER_CONSUMER_KEY=$(TWITTER_CONSUMER_KEY) \
	--build-arg TWITTER_ACCESS_TOKEN=$(TWITTER_ACCESS_TOKEN) \
	--build-arg TWITTER_CONSUMER_SECRET=$(TWITTER_CONSUMER_SECRET) \
	--build-arg TWITTER_TOKEN_SECRET=$(TWITTER_TOKEN_SECRET) \
	-t sentweet:latest .

network:
	docker network create bitfeels

run:
	docker run \
	--network bitfeels \
	--name sentweet \
	--publish 127.0.0.1:4000:4000/tcp \
	sentweet:latest

push:
	docker tag sentweet:latest thekeele/sentweet:latest
	docker push thekeele/sentweet
