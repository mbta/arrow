ARG ELIXIR_VERSION=1.18.0
ARG ERLANG_VERSION=27.2
ARG DEBIAN_VERSION=bullseye-20241202

FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-debian-$DEBIAN_VERSION as elixir-builder

ENV LANG=C.UTF-8 \
  MIX_ENV=prod

RUN apt-get update --allow-releaseinfo-change && \
  apt-get install -y --no-install-recommends ca-certificates curl git gnupg

RUN mix local.hex --force && \
  mix local.rebar --force

RUN curl https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
  -o /root/aws-cert-bundle.pem
RUN echo "390fdc813e2e58ec5a0def8ce6422b83d75032899167052ab981d8e1b3b14ff2 /root/aws-cert-bundle.pem" | sha256sum -c -

# Instructions from:
# https://github.com/nodesource/distributions#debian-versions

ARG NODE_MAJOR=20

RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" >> /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && \
  apt-get install nodejs -y

WORKDIR /app

COPY mix.exs mix.exs
COPY mix.lock mix.lock

RUN mix do deps.get --only prod

COPY config/config.exs config/
COPY config/prod.exs config/

RUN mix deps.compile
RUN mix sentry.package_source_code

COPY assets assets
RUN npm ci --prefix assets

COPY lib lib
RUN mix assets.deploy

COPY priv priv

RUN mix phx.digest
RUN mix compile

COPY config/runtime.exs config
RUN cp /root/aws-cert-bundle.pem priv/

RUN mix release

FROM debian:$DEBIAN_VERSION

RUN apt-get update --allow-releaseinfo-change && \
  apt-get install -y --no-install-recommends \
  libssl1.1 libsctp1 curl ca-certificates && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN chown nobody /app

EXPOSE 4000
ENV MIX_ENV=prod TERM=xterm LANG="C.UTF-8" PORT=4000 PHX_SERVER=true

COPY --from=elixir-builder --chown=nobody:root /app/_build/prod/rel/arrow .

# Ensure SSL support is enabled
RUN env SECRET_KEY_BASE=fake DATABASE_PORT=0 \
  sh -c ' \
  /app/bin/arrow eval ":crypto.supports()" && \
  /app/bin/arrow eval ":ok = :public_key.cacerts_load"'

CMD ["/app/bin/arrow", "start"]
