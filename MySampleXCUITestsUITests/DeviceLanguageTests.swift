
import XCTest

final class DeviceLanguageUITests: XCTestCase {

    // MARK: - Test: Device Language

    @MainActor
    func testDeviceLanguage() throws {

        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")

        settings.terminate()
        settings.activate()

        let language = Locale.preferredLanguages.first ?? ""

        print("\n========== LANGUAGE CHECK ==========")
        print("Device language: \(language)")
        print("====================================\n")

        if language.hasPrefix("en") {
            print("Device is already using English. No changes required.")
            return
        }

        setEnglish(settings)
    }

    // MARK: - Language Helpers

    @MainActor
    func setEnglish(_ settings: XCUIApplication) {

        let majorVersion = ProcessInfo.processInfo.operatingSystemVersion.majorVersion

        print("iOS Version: \(majorVersion)")

        if majorVersion >= 27 {

            let languageAndRegion =
                settings.buttons["com.apple.settings.general.languageAndRegion"]

            scrollToElement(languageAndRegion, in: settings)

        } else {

            let general = settings.buttons["com.apple.settings.general"]

            scrollToElement(general, in: settings)

            let international = settings.buttons["INTERNATIONAL"]

            scrollToElement(international, in: settings)
        }

        let addLanguage = settings.buttons["ADD_PREFERRED_LANGUAGE"]

        if addLanguage.waitForExistence(timeout: 5) {
            addLanguage.tap()
        }

        let english = settings.staticTexts.allElementsBoundByIndex.first {
            $0.label.contains("English")
        }

        guard let english = english else {
            XCTFail("English language option not found")
            return
        }

        english.tap()

        // Wait for the language confirmation popup.
        let popupButtons = settings.buttons
        let englishConfirmation = popupButtons.element(boundBy: 1)

        XCTAssertTrue(
            englishConfirmation.waitForExistence(timeout: 10),
            "English confirmation popup did not appear"
        )

        print("Selecting English as the preferred language")

        // Button index 1 is the Use English action.
        englishConfirmation.tap()

        print("English language selection confirmed")
    }

    @MainActor
    func scrollToElement(
        _ element: XCUIElement,
        in application: XCUIApplication
    ) {

        var attempts = 0

        while !element.exists && attempts < 10 {
            application.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(
            element.waitForExistence(timeout: 5),
            "Element not found: \(element)"
        )

        element.tap()
    }
}

