
import XCTest
final class TapoAlert: XCTestCase {
    func testTapoAlert() throws {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        if settings.state == .runningForeground || settings.state == .runningBackground { settings.terminate() }
        settings.launch()
        
        let notifications = settings.buttons["com.apple.settings.notifications"].firstMatch
        for _ in 0..<10 {
            if notifications.isHittable { break }
            settings.swipeUp()
        }
        XCTAssertTrue(notifications.isHittable, "Notifications not visible")
        notifications.tap()
        
        let tapo = settings.staticTexts["Tapo"].firstMatch
        while !tapo.exists && settings.scrollViews.firstMatch.exists {
            settings.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(tapo.waitForExistence(timeout: 5), "Tapo not found")
        tapo.tap()

        let cell = settings.cells["ALLOW_NOTIFICATIONS_ID"]
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Allow Notifications cell not found")

        // Inner unlabeled switch is the last switch in the cell
        let toggle = cell.switches.element(boundBy: cell.switches.count - 1)
        XCTAssertTrue(toggle.exists, "Toggle not found")

        // ON -> turn OFF, OFF -> turn ON
        toggle.tap()

        // Dismiss a confirmation alert if iOS shows one
        let alert = settings.alerts.firstMatch
        if alert.waitForExistence(timeout: 2) {
            let confirm = alert.buttons["Turn Off"].exists ? alert.buttons["Turn Off"] : alert.buttons.firstMatch
            confirm.tap()
        }
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.terminate()                 // close Settings
        XCUIDevice.shared.press(.home)       // leave the device on the home screen
    }
}

