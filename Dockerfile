FROM elixir:1.9 as build

RUN mix local.rebar --force && \
    mix local.hex --force

WORKDIR /app
ENV MIX_ENV=prod
COPY mix.* /app/
RUN mix deps.get --only prod
RUN mix deps.compile

FROM node:10.16 as frontend

WORKDIR /app
COPY assets/package.json assets/package-lock.json /app/
COPY --from=build /app/deps/phoenix /deps/phoenix
COPY --from=build /app/deps/phoenix_html /deps/phoenix_html

RUN npm install

COPY assets /app
RUN npm run deploy

FROM build as release
COPY --from=frontend /priv/static /app/priv/static
COPY . /app/
RUN mix phx.digest
RUN mix release --env=prod --no-tar

ARG TWITTER_CONSUMER_KEY
ARG TWITTER_ACCESS_TOKEN
ARG TWITTER_CONSUMER_SECRET
ARG TWITTER_TOKEN_SECRET

ENV TWITTER_CONSUMER_KEY $TWITTER_CONSUMER_KEY
ENV TWITTER_ACCESS_TOKEN $TWITTER_ACCESS_TOKEN
ENV TWITTER_CONSUMER_SECRET $TWITTER_CONSUMER_SECRET
ENV TWITTER_TOKEN_SECRET $TWITTER_TOKEN_SECRET

EXPOSE 4000
CMD _build/prod/rel/sen_tweet/bin/sen_tweet foreground
