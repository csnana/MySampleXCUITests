#!/bin/bash
set -euo pipefail

# Required environment variables:
#   DEVICE_ID     - device UDID (find it with: xcrun devicectl list devices)
#   SIGN_IDENTITY - code signing identity name or hash
#                   (find it with: security find-identity -v -p codesigning)
: "${DEVICE_ID:?Set DEVICE_ID}"
: "${SIGN_IDENTITY:?Set SIGN_IDENTITY}"

PROJECT="MySampleXCUITests.xcodeproj"
SCHEME="TapoAlert"
ICON="TapoAlert/Assets.xcassets/AppIcon.appiconset/TapoToggle Orange Bell Icon.png"
DD="/tmp/dd"
APP="$DD/Build/Products/Debug-iphoneos/TapoAlert-Runner.app"

# 1. Build the runner
xcodebuild build-for-testing -project "$PROJECT" -scheme "$SCHEME" \
  -destination "platform=iOS,id=$DEVICE_ID" -derivedDataPath "$DD" \
  -allowProvisioningUpdates

# 2. Add icon files
sips -z 120 120 "$ICON" --out "$APP/RunnerIcon60x60@2x.png"
sips -z 180 180 "$ICON" --out "$APP/RunnerIcon60x60@3x.png"

# 3. Point Info.plist at them
plutil -replace CFBundleIcons -json \
  '{"CFBundlePrimaryIcon":{"CFBundleIconFiles":["RunnerIcon60x60"],"CFBundleIconName":"RunnerIcon"}}' \
  "$APP/Info.plist"

# 4. Re-sign and verify
codesign -f -s "$SIGN_IDENTITY" --preserve-metadata=entitlements,identifier,flags "$APP"
codesign -v "$APP" && echo "Signature OK"

# 5. Install on the device
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"
