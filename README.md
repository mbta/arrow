# Arrow

🏹 Adjustments to the Regular Right of Way

## Setup

### Requirements

- [`asdf`](https://github.com/asdf-vm/asdf)
  - Add `erlang`, `elixir`, and `nodejs` plugins
  - Install [additional requirements][nodejs-reqs] for `nodejs` plugin
- [`direnv`](https://github.com/direnv/direnv)
- PostgreSQL 15
  - Can be run as a container via docker-compose by running `docker-compose up -d` in this repository (see `docker-compose.yml`)
  - Using Homebrew: `brew install postgresql@15`
- OpenRouteService
  - Can use https://api.openrouteservice.org/ with an API key requested through their console
  - Or the docker-compose setup [with Docker Desktop alternative](https://github.com/mbta/technology-docs/blob/main/rfcs/accepted/0010-docker-desktop-replacement.md), no API key needed

[nodejs-reqs]: https://github.com/asdf-vm/asdf-nodejs#requirements

### Instructions

- `asdf install`
- `mix deps.get`
- `mix esbuild.install`
- `npm install --prefix assets`
- `cp .envrc.example .envrc`
- Update `.envrc` with your local Postgres username and password
- Update `.envrc` with your AWS credentials or ensure they are available in your shell
- Update `.envrc` with OpenRouteService setup
- Update `.envrc` with the Arrow Dev Keycloak client secret (found in 1Password)
- `direnv allow`
- `mix ecto.setup`
- `brew install chromedriver`
- Add your Arrow API key from https://arrow.mbta.com/mytoken to `.envrc`
- `mix copy_db` to seed your database
- `mix import_gtfs [optional/path/to/local/MBTA_GTFS.zip]` to populate your database's `gtfs_*` tables from a GTFS-static feed

### Useful commands

- Run the app: `mix phx.server` (visit <http://localhost:4000/>)
- Elixir:
  - `mix test` — run tests
  - `mix test.integration` — run integration tests
  - `mix dialyzer` — check typespecs
  - `mix format` — format code
  - `mix credo` — lint code
- JavaScript: `cd assets` and...
  - `npm run test` — run tests
  - `npm run test -- --watch` — run tests continuously for changed code
  - `npm run format` — format code
  - `npm run lint` — lint code (and fix automatically if possible)
