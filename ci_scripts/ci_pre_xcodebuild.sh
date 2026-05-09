#!/bin/sh
set -e

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES || true
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES || true

python3 << 'PYEOF'
import base64, os, plistlib, sys

repo_path = os.environ.get('CI_PRIMARY_REPOSITORY_PATH') or '/Volumes/workspace/repository'
print('[CI] Repository path:', repo_path)
print('[CI] Python version:', sys.version)

# ── GoogleService-Info.plist ──────────────────────────────────
b64 = os.environ.get('GOOGLE_SERVICE_INFO_PLIST_MAIN', '').strip()
if not b64:
    print('[CI] ERROR: GOOGLE_SERVICE_INFO_PLIST_MAIN is not set', file=sys.stderr)
    sys.exit(1)

try:
    google_plist_data = base64.decodebytes(b64.encode())
except Exception as e:
    print('[CI] ERROR: base64 decode failed:', e, file=sys.stderr)
    sys.exit(1)

try:
    plistlib.loads(google_plist_data)
except Exception as e:
    print('[CI] ERROR: GoogleService-Info.plist is not a valid plist:', e, file=sys.stderr)
    sys.exit(1)

for dest in [
    repo_path + '/SubwayWhen/Application/GoogleService-Info.plist',
    repo_path + '/SubwayWhenHomeWidget/GoogleService-Info.plist',
]:
    try:
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, 'wb') as f:
            f.write(google_plist_data)
        print('[CI] Created:', dest)
    except Exception as e:
        print('[CI] ERROR: failed to write', dest + ':', e, file=sys.stderr)
        sys.exit(1)

# ── RequestToken.plist ────────────────────────────────────────
token_keys = ['REALTIME_TOKEN', 'LIVE_TOKEN', 'KORAIL_TOKEN', 'SEOUL_TOKEN', 'KAKAO_TOKEN']
for key in token_keys:
    if not os.environ.get(key):
        print('[CI] WARNING:', key, 'is not set', file=sys.stderr)

token_path = repo_path + '/SubwayWhen/RequestToken.plist'
try:
    os.makedirs(os.path.dirname(token_path), exist_ok=True)
    with open(token_path, 'wb') as f:
        plistlib.dump(
            {k: os.environ.get(k, '') for k in token_keys},
            f,
            fmt=plistlib.FMT_XML,
        )
    print('[CI] Created:', token_path)
except Exception as e:
    print('[CI] ERROR: failed to write RequestToken.plist:', e, file=sys.stderr)
    sys.exit(1)
PYEOF
