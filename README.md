# Arrow

🏹 Adjustments to the Regular Right of Way

## Setup

### Requirements

- [`asdf`](https://github.com/asdf-vm/asdf)
  - Add `erlang`, `elixir`, and `nodejs` plugins
  - Install [additional requirements][nodejs-reqs] for `nodejs` plugin
- [`direnv`](https://github.com/direnv/direnv)
- PostgreSQL 11 (using Homebrew: `brew install postgresql@11`)

[nodejs-reqs]: https://github.com/asdf-vm/asdf-nodejs#requirements

### Instructions

- `asdf install`
- `mix deps.get`
- `mix esbuild.install`
- `npm install --prefix assets`
- `cp .envrc.example .envrc`
- Update `.envrc` with your local Postgres username and password
- `direnv allow`
- `mix ecto.setup`
- `brew install chromedriver`

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
