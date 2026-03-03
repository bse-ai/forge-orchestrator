#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${FORGE_ORCH_IMAGE:-${FORGE_ORCH_IMAGE:-forge-orchestrator:local}}"
CONFIG_DIR="${FORGE_ORCH_CONFIG_DIR:-${FORGE_ORCH_CONFIG_DIR:-$HOME/.forge-orchestrator}}"
WORKSPACE_DIR="${FORGE_ORCH_WORKSPACE_DIR:-${FORGE_ORCH_WORKSPACE_DIR:-$HOME/.forge-orchestrator/workspace}}"
PROFILE_FILE="${FORGE_ORCH_PROFILE_FILE:-${FORGE_ORCH_PROFILE_FILE:-$HOME/.profile}}"

PROFILE_MOUNT=()
if [[ -f "$PROFILE_FILE" ]]; then
  PROFILE_MOUNT=(-v "$PROFILE_FILE":/home/node/.profile:ro)
fi

echo "==> Build image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$ROOT_DIR/Dockerfile" "$ROOT_DIR"

echo "==> Run live model tests (profile keys)"
docker run --rm -t \
  --entrypoint bash \
  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -e HOME=/home/node \
  -e NODE_OPTIONS=--disable-warning=ExperimentalWarning \
  -e OPENCLAW_LIVE_TEST=1 \
  -e OPENCLAW_LIVE_MODELS="${OPENCLAW_LIVE_MODELS:-${CLAWDBOT_LIVE_MODELS:-modern}}" \
  -e OPENCLAW_LIVE_PROVIDERS="${OPENCLAW_LIVE_PROVIDERS:-${CLAWDBOT_LIVE_PROVIDERS:-}}" \
  -e OPENCLAW_LIVE_MAX_MODELS="${OPENCLAW_LIVE_MAX_MODELS:-${CLAWDBOT_LIVE_MAX_MODELS:-48}}" \
  -e OPENCLAW_LIVE_MODEL_TIMEOUT_MS="${OPENCLAW_LIVE_MODEL_TIMEOUT_MS:-${CLAWDBOT_LIVE_MODEL_TIMEOUT_MS:-}}" \
  -e OPENCLAW_LIVE_REQUIRE_PROFILE_KEYS="${OPENCLAW_LIVE_REQUIRE_PROFILE_KEYS:-${CLAWDBOT_LIVE_REQUIRE_PROFILE_KEYS:-}}" \
  -v "$CONFIG_DIR":/home/node/.openclaw \
  -v "$WORKSPACE_DIR":/home/node/.openclaw/workspace \
  "${PROFILE_MOUNT[@]}" \
  "$IMAGE_NAME" \
  -lc "set -euo pipefail; [ -f \"$HOME/.profile\" ] && source \"$HOME/.profile\" || true; cd /app && pnpm test:live"
