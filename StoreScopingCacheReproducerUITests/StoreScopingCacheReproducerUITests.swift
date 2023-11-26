import XCTest

final class StoreScopingCacheReproducerUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testSectionHeaderText() throws {
    let app = XCUIApplication()
    app.launch()

    app.buttons["A to Z"].tap()
    let headerA = app.collectionViews.element(boundBy: 0).cells.element(boundBy: 0)
    XCTAssertEqual(headerA.label, "9")

    app.buttons["Z to A"].tap()
    let headerZ = app.collectionViews.element(boundBy: 0).cells.element(boundBy: 0)
    XCTAssertEqual(headerZ.label, "W")
  }
}
