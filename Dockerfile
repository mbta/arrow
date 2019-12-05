FROM erlang:22.1.7 as builder

ENV ELIXIR_VERSION="v1.9.1" \
  LANG=C.UTF-8 \
  MIX_ENV=prod

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
  && ELIXIR_DOWNLOAD_SHA256="94daa716abbd4493405fb2032514195077ac7bc73dc2999922f13c7d8ea58777" \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean

# Instructions from:
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
RUN  curl -sL https://deb.nodesource.com/setup_13.x | bash - \
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

FROM debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends \
  libssl1.1 libsctp1 curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root
EXPOSE 4000
ENV MIX_ENV=prod TERM=xterm LANG="C.UTF-8" PORT=4000

COPY --from=builder /root/_build/prod/rel/arrow .

CMD ["bin/arrow", "start"]
