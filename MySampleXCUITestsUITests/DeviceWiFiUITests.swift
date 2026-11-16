
import XCTest

final class DeviceWiFiUITests: XCTestCase {

    // MARK: - Test: Default Wi-Fi

    @MainActor
    func testDefaultWifi() throws {

        let wifiMap = [
            "00008140-00125C303E28401C": "GetOffMyNetwork",
        ]

        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")

        settings.terminate()
        settings.activate()

        guard let deviceUDID = ProcessInfo.processInfo.environment[
            "RUN_DESTINATION_DEVICE_UDID"
        ] else {
            XCTFail("Unable to retrieve device UDID")
            return
        }

        guard let expectedWiFi = wifiMap[deviceUDID] else {
            XCTFail("No Wi-Fi mapping found for device UDID: \(deviceUDID)")
            return
        }

        print("\n========== WIFI CHECK ==========")
        print("Device UDID: \(deviceUDID)")
        print("Expected Wi-Fi: \(expectedWiFi)")
        print("================================\n")

        let wifiButton = getWiFiButton(settings)

        if getWiFiStatus(wifiButton) == "Off" {
            enableWiFi(settings)
        }

        validateWiFi(settings: settings, expectedWiFi: expectedWiFi)
    }

    // MARK: - Wi-Fi Helpers

    @MainActor
    func getWiFiButton(_ settings: XCUIApplication) -> XCUIElement {

        let wifiButton = settings.buttons["com.apple.settings.wifi"]

        XCTAssertTrue(
            wifiButton.waitForExistence(timeout: 10),
            "Wi-Fi button not found"
        )

//        wifiButton.tap()

        return wifiButton
    }

    @MainActor
    func getWiFiStatus(_ wifiButton: XCUIElement) -> String {

        let label = wifiButton.label

        print("Wi-Fi accessibility label: \(label)")

        if label.contains("Off") {
            return "Off"
        }

        return "On"
    }

    @MainActor
    func enableWiFi(_ settings: XCUIApplication) {

        print("Wi-Fi is OFF. Enabling Wi-Fi.")

        let wifiSwitch = settings.switches.firstMatch

        XCTAssertTrue(
            wifiSwitch.waitForExistence(timeout: 10),
            "Wi-Fi switch not found"
        )

        if wifiSwitch.value as? String == "0" {
            wifiSwitch.tap()
        }

        print("Wi-Fi enable command executed")
    }

    @MainActor
    func getConnectedWiFi(_ settings: XCUIApplication) -> String {

        let wifiButton = settings.buttons["com.apple.settings.wifi"]

        let label = wifiButton.label

        print("Current Wi-Fi label: \(label)")

        if label.contains("Wi-Fi, ") {
            return String(label.dropFirst("Wi-Fi, ".count))
        }

        return label
    }

    @MainActor
    func validateWiFi(
        settings: XCUIApplication,
        expectedWiFi: String
    ) {

        let actualWiFi = getConnectedWiFi(settings)

        print("\n========== WIFI VALIDATION ==========")
        print("Expected Wi-Fi: \(expectedWiFi)")
        print("Actual Wi-Fi: \(actualWiFi)")
        print("=====================================\n")

        XCTAssertEqual(
            actualWiFi.lowercased(),
            expectedWiFi.lowercased(),
            "Incorrect Wi-Fi network. Expected: \(expectedWiFi), Actual: \(actualWiFi)"
        )
    }
}

