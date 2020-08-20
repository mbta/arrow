#!/bin/bash
set -ex

mix compile --force --warnings-as-errors
mix credo --strict
