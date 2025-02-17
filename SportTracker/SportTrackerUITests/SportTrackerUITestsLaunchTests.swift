import XCTest

final class SportTrackerUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let listTab = app.tabBars.buttons["List"]
        XCTAssertTrue(listTab.exists, "The List tab should be available after app launch.")
        
        if !listTab.isSelected {
            listTab.tap()
        }

        let performanceListNavigationBar = app.navigationBars["Performance List"]
        XCTAssertTrue(performanceListNavigationBar.exists, "Performance List screen should be shown after launch.")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
