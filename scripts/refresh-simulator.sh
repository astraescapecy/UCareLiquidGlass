#!/usr/bin/env bash
# Regenerate Xcode project, build for simulator, install, and launch UCareLiquidGlass.
# Run from repo root: bash scripts/refresh-simulator.sh

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not on PATH; install from https://github.com/yonaskolb/XcodeGen" >&2
  exit 1
fi

xcodegen generate

# Prefer a booted iPhone simulator; else first available iPhone.
UDID="$(xcrun simctl list devices available -j 2>/dev/null | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
for run in d.get('devices', {}).values():
    for dev in run:
        if dev.get('state') != 'Booted':
            continue
        if 'iPhone' in dev.get('name', ''):
            print(dev['udid'])
            raise SystemExit
for run in d.get('devices', {}).values():
    for dev in run:
        if 'iPhone' in dev.get('name', '') and dev.get('isAvailable', True):
            print(dev['udid'])
            raise SystemExit
" 2>/dev/null || true)"

if [[ -z "${UDID:-}" ]]; then
  echo "No iPhone simulator found; boot one in Xcode or Simulator.app first." >&2
  exit 1
fi

xcrun simctl boot "$UDID" 2>/dev/null || true

DERIVED="$ROOT/.build/DerivedData"
xcodebuild \
  -project UCareLiquidGlass.xcodeproj \
  -scheme UCareLiquidGlass \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  build

APP="$DERIVED/Build/Products/Debug-iphonesimulator/UCareLiquidGlass.app"
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" com.ucare.liquidglass
open -a Simulator 2>/dev/null || true
echo "Installed and launched on $UDID"
