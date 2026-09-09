#!/usr/bin/env bash

if [[ -z "${CLAUDE_ENV_FILE:-}" ]]; then
  echo "Warning: CLAUDE_ENV_FILE not set — skipping env setup" >&2
  exit 0
fi

direnv allow || true
direnv export bash >> "$CLAUDE_ENV_FILE"
