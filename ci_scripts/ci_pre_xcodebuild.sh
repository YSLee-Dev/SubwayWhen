#!/bin/sh
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

REPO_PATH="${CI_PRIMARY_REPOSITORY_PATH:-/Volumes/workspace/repository}"

echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhen/Application/GoogleService-Info.plist"
echo "$GOOGLE_SERVICE_INFO_PLIST_MAIN" | base64 --decode > "$REPO_PATH/SubwayWhenHomeWidget/GoogleService-Info.plist"

PLIST="$REPO_PATH/SubwayWhen/RequestToken.plist"
/usr/libexec/PlistBuddy -c "Add :REALTIME_TOKEN string ${REALTIME_TOKEN}" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :LIVE_TOKEN string ${LIVE_TOKEN}" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :KORAIL_TOKEN string ${KORAIL_TOKEN}" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :SEOUL_TOKEN string ${SEOUL_TOKEN}" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :KAKAO_TOKEN string ${KAKAO_TOKEN}" "$PLIST"
