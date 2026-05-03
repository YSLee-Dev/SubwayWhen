#!/bin/sh
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

REPO_PATH="${CI_PRIMARY_REPOSITORY_PATH:-/Volumes/workspace/repository}"

echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhen/Application/GoogleService-Info.plist"
echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhenHomeWidget/GoogleService-Info.plist"

python3 << 'PYEOF'
import plistlib, os

repo_path = os.environ.get('CI_PRIMARY_REPOSITORY_PATH') or '/Volumes/workspace/repository'
plist_path = repo_path + '/SubwayWhen/RequestToken.plist'

data = {
    'REALTIME_TOKEN': os.environ.get('REALTIME_TOKEN', ''),
    'LIVE_TOKEN':     os.environ.get('LIVE_TOKEN', ''),
    'KORAIL_TOKEN':   os.environ.get('KORAIL_TOKEN', ''),
    'SEOUL_TOKEN':    os.environ.get('SEOUL_TOKEN', ''),
    'KAKAO_TOKEN':    os.environ.get('KAKAO_TOKEN', ''),
}

with open(plist_path, 'wb') as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_XML)

print('RequestToken.plist created at:', plist_path)
PYEOF
