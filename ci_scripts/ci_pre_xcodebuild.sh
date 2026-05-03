#!/bin/sh
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

REPO_PATH="${CI_PRIMARY_REPOSITORY_PATH:-/Volumes/workspace/repository}"

echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhen/Application/GoogleService-Info.plist"
echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhenHomeWidget/GoogleService-Info.plist"

cat > "$REPO_PATH/SubwayWhen/RequestToken.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>REALTIME_TOKEN</key>
    <string>$REALTIME_TOKEN</string>
    <key>LIVE_TOKEN</key>
    <string>$LIVE_TOKEN</string>
    <key>KORAIL_TOKEN</key>
    <string>$KORAIL_TOKEN</string>
    <key>SEOUL_TOKEN</key>
    <string>$SEOUL_TOKEN</string>
    <key>KAKAO_TOKEN</key>
    <string>$KAKAO_TOKEN</string>
</dict>
</plist>
EOF
