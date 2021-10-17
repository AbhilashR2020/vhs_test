FROM erlang:23.3.4-alpine as build

RUN apk --no-cache add openssh git make build-base curl

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.12.1" \
    LANG=C.UTF-8

RUN set -xe \
    && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
    && ELIXIR_DOWNLOAD_SHA256="96167d614b9c483efc54bd7898c3eea4768569a77dd8892ada85d7800d5e3ea4" \
    && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
    && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/local/src/elixir \
    && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
    && rm elixir-src.tar.gz \
    && cd /usr/local/src/elixir \
    && make install clean

ENV MIX_ENV prod

RUN apk --no-cache add openssh git make build-base

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mkdir /app-build
WORKDIR /app-build

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

COPY config ./config
COPY mix.exs mix.exs
COPY mix.lock mix.lock
RUN --mount=type=ssh mix deps.get --only prod
RUN mix deps.compile
COPY lib ./lib

FROM alpine:3.13
RUN apk --no-cache add ca-certificates netcat-openbsd libgcc libstdc++ mc vim bash ncurses curl jq htop procps

CMD ["iex", "-S" "mix"]
