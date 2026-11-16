# MySampleXCUITests

A small collection of XCUITest tests for iOS devices. The repo contains three tests:

| Test | File | What it checks |
|------|------|----------------|
| Tapo notification toggle | `TapoAlert/TapoAlert.swift` | Toggles **Allow Notifications** for the Tapo app in iOS Settings |
| Device language | `MySampleXCUITestsUITests/DeviceLanguageTests.swift` | Checks that the device language is English |
| Device Wi-Fi | `MySampleXCUITestsUITests/DeviceWiFiUITests.swift` | Checks that the device is connected to the default Wi-Fi network |

## Test details

### 1. TapoAlert (`TapoAlert/TapoAlert.swift`)

`testTapoAlert` automates the iOS Settings app:

1. Launches Settings (restarting it if already running).
2. Scrolls to and opens **Notifications**.
3. Scrolls to **Tapo** and opens it.
4. Taps the **Allow Notifications** switch (ON becomes OFF, OFF becomes ON), confirming the alert if iOS shows one.
5. Closes Settings and returns the device to the home screen.

### 2. Device language (`MySampleXCUITestsUITests/DeviceLanguageTests.swift`)

- Checks whether the device language is set to English. 
- Please make sure the accesibility ids are correct for older version of iOS. Currently works for iOS 18 and above

### 3. Device Wi-Fi (`MySampleXCUITestsUITests/DeviceWiFiUITests.swift`)

- Checks whether the device is connected to the default Wi-Fi network. 
- Device and wifi mapping provided inside the script. 

## Running the tests

From Xcode: pick the scheme that contains the test, choose your device, and press **Cmd+U**. To run a single test, click the diamond next to it in the editor gutter.

From the command line:

```bash
xcodebuild test \
  -project MySampleXCUITests.xcodeproj \
  -scheme <scheme-name> \
  -destination 'platform=iOS,id=<your-device-id>'
```

Find your device ID with `xcrun devicectl list devices`. To run one test, add `-only-testing:<TargetName>/<ClassName>/<testMethod>`.

## Custom runner icon (optional) 

Xcode generates the runner app (`TapoAlert-Runner.app`) with a blank home screen icon, and settings on the test target do not change it. `patch-runner-icon.sh` builds the runner, adds an icon, re-signs it, and installs it on your device.

```bash
chmod +x patch-runner-icon.sh
DEVICE_ID=<your-device-id> SIGN_IDENTITY=<your-signing-identity> ./patch-runner-icon.sh
```

- Find your signing identity with `security find-identity -v -p codesigning`.
- Delete any old runner from the device first, since iOS caches the old icon.
- To run tests without Xcode rebuilding (and wiping the icon), use `xcodebuild test-without-building` with `-derivedDataPath /tmp/dd`.
- Building again from Xcode or with `build-for-testing` regenerates the runner, so rerun the script afterwards.

## Notes

- The Tapo test relies on iOS Settings accessibility identifiers, which can change between iOS versions.
- The Tapo test toggles the setting each time it runs, so the final state depends on the starting state.
