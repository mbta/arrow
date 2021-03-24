FROM hexpm/elixir:1.9.4-erlang-22.2.1-debian-buster-20200224 as builder

ENV LANG=C.UTF-8 \
  MIX_ENV=prod

# Instructions from:
# https://github.com/nodesource/distributions/blob/master/README.md
RUN  curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

WORKDIR /root
ADD . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix do deps.get --only prod, compile --force && \
    npm --prefix assets ci && \
    npm --prefix assets run deploy && \
    mix phx.digest && \
    mix release

FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
  libssl1.1 libsctp1 curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root
EXPOSE 4000
ENV MIX_ENV=prod TERM=xterm LANG="C.UTF-8" PORT=4000

COPY --from=builder /root/_build/prod/rel/arrow .

CMD ["bin/arrow", "start"]
