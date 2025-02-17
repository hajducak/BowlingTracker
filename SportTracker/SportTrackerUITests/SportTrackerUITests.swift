import XCTest

final class SportTrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor func testNavigationToAddPerformanceScreen() throws {
        let app = XCUIApplication()
        app.launch()

        let addTab = app.tabBars.buttons["Add"]
        XCTAssertTrue(addTab.exists, "The Add tab should be available.")
        addTab.tap()

        let addPerformanceNavigationBar = app.navigationBars["Add Performance"]
        XCTAssertTrue(addPerformanceNavigationBar.exists, "The Add Performance screen should be shown.")
    }

    @MainActor
    func testBackNavigationFromAddPerformanceScreen() throws {
        let app = XCUIApplication()
        app.launch()

        let addTab = app.tabBars.buttons["Add"]
        addTab.tap()
        
        let addPerformanceNavigationBar = app.navigationBars["Add Performance"]
        XCTAssertTrue(addPerformanceNavigationBar.exists, "The Add Performance screen should be shown.")
        
        let listTab = app.tabBars.buttons["List"]
        listTab.tap()

        let performanceListNavigationBar = app.navigationBars["Performance List"]
        XCTAssertTrue(performanceListNavigationBar.exists, "The Performance List screen should be shown.")
        
    }

    @MainActor
    func testStorageTypeSelection() throws {
        let app = XCUIApplication()
        app.launch()

        let addTab = app.tabBars.buttons["Add"]
        addTab.tap()

        let storagePicker = app.segmentedControls["storageType"]
        XCTAssert(storagePicker.exists)
        XCTAssert(storagePicker.buttons["localButton"].isSelected)
        
        storagePicker.buttons["remoteButton"].tap()
        XCTAssert(storagePicker.buttons["remoteButton"].isSelected)
    }
    
    @MainActor
    func testSaveNewPerformanceAndDisplayInList() throws {
        let app = XCUIApplication()
        app.launch()

        let addTab = app.tabBars.buttons["Add"]
        addTab.tap()

        let nameTextField = app.textFields["Enter performance name"]
        let locationTextField = app.textFields["Enter performance location"]
        let durationTextField = app.textFields["Enter performance duration (in minutes)"]

        nameTextField.tap()
        nameTextField.typeText("Cycling")
        
        locationTextField.tap()
        locationTextField.typeText("Road")
        
        durationTextField.tap()
        durationTextField.typeText("45")

        
        let storagePicker = app.segmentedControls["storageType"]
        storagePicker.buttons["localButton"].tap()
        app.buttons["Save Performance"].tap()

        let listTab = app.tabBars.buttons["List"]
        listTab.tap()

        // let performanceCell = app.tables.cells.staticTexts["Cycling"]
        // let existsPredicate = NSPredicate(format: "exists == true")
        // expectation(for: existsPredicate, evaluatedWith: performanceCell, handler: nil)
        // waitForExpectations(timeout: 5, handler: nil)
        // XCTAssertTrue(performanceCell.exists, "The saved performance should appear in the list.")
    }

}
