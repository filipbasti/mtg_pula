#!/usr/bin/env bash
# exit on error
set -o errexit


mix deps.get --only prod
MIX_ENV=prod mix compile


# Create server script, Build the release, and overwrite the existing release directory
MIX_ENV=prod mix phx.gen.release
MIX_ENV=prod mix release --overwrite