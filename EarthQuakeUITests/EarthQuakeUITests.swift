//
//  EarthQuakeUITests.swift
//  EarthQuakeUITests
//
//  Created by Aaron Ruth on 10/7/15.
//  Copyright © 2015 Aaron Ruth. All rights reserved.
//

import XCTest

class EarthQuakeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialLoad() {
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 11)
        XCTAssertTrue(compareEarthQuakeData(0, earthQuakeDataIndex: 0))
        XCTAssertTrue(compareEarthQuakeData(1, earthQuakeDataIndex: 1))
        XCTAssertTrue(compareEarthQuakeData(2, earthQuakeDataIndex: 2))
        XCTAssertTrue(compareEarthQuakeData(3, earthQuakeDataIndex: 3))
        XCTAssertTrue(compareEarthQuakeData(4, earthQuakeDataIndex: 4))
        XCTAssertTrue(compareEarthQuakeData(5, earthQuakeDataIndex: 5))
        XCTAssertTrue(compareEarthQuakeData(6, earthQuakeDataIndex: 6))
        XCTAssertTrue(compareEarthQuakeData(7, earthQuakeDataIndex: 7))
        XCTAssertTrue(compareEarthQuakeData(8, earthQuakeDataIndex: 8))
        XCTAssertTrue(compareEarthQuakeData(9, earthQuakeDataIndex: 9))
        XCTAssertTrue(compareEarthQuakeData(10, earthQuakeDataIndex: 10))
    }
    
    func testDeleteCell2() {
        
        //delete cell 2
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Tue, 08 Dec 2015 08:27:04"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 10)
        XCTAssertTrue(compareEarthQuakeData(0, earthQuakeDataIndex: 0))
        XCTAssertTrue(compareEarthQuakeData(1, earthQuakeDataIndex: 2))
        XCTAssertTrue(compareEarthQuakeData(2, earthQuakeDataIndex: 3))
        XCTAssertTrue(compareEarthQuakeData(3, earthQuakeDataIndex: 4))
        XCTAssertTrue(compareEarthQuakeData(4, earthQuakeDataIndex: 5))
        XCTAssertTrue(compareEarthQuakeData(5, earthQuakeDataIndex: 6))
        XCTAssertTrue(compareEarthQuakeData(6, earthQuakeDataIndex: 7))
        XCTAssertTrue(compareEarthQuakeData(7, earthQuakeDataIndex: 8))
        XCTAssertTrue(compareEarthQuakeData(8, earthQuakeDataIndex: 9))
        XCTAssertTrue(compareEarthQuakeData(9, earthQuakeDataIndex: 10))
    }
    
    func testDeleteCell1() {
        
        //delete cell 1
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Tue, 08 Dec 2015 08:46:28"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 10)
        XCTAssertTrue(compareEarthQuakeData(0, earthQuakeDataIndex: 1))
        XCTAssertTrue(compareEarthQuakeData(1, earthQuakeDataIndex: 2))
        XCTAssertTrue(compareEarthQuakeData(2, earthQuakeDataIndex: 3))
        XCTAssertTrue(compareEarthQuakeData(3, earthQuakeDataIndex: 4))
        XCTAssertTrue(compareEarthQuakeData(4, earthQuakeDataIndex: 5))
        XCTAssertTrue(compareEarthQuakeData(5, earthQuakeDataIndex: 6))
        XCTAssertTrue(compareEarthQuakeData(6, earthQuakeDataIndex: 7))
        XCTAssertTrue(compareEarthQuakeData(7, earthQuakeDataIndex: 8))
        XCTAssertTrue(compareEarthQuakeData(8, earthQuakeDataIndex: 9))
        XCTAssertTrue(compareEarthQuakeData(9, earthQuakeDataIndex: 10))
    }

    func testDeleteCell11() {
        
        //delete cell 11
        let tablesQuery = XCUIApplication().tables
        let firstCell = tablesQuery.staticTexts["Sat, 05 Dec 2015 16:56:26"]
        let lastCell = tablesQuery.staticTexts["Tue, 08 Dec 2015 08:46:28"]
        firstCell.pressForDuration(0, thenDragToElement: lastCell)
        tablesQuery.staticTexts["Fri, 04 Dec 2015 10:15:25"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 10)
        XCTAssertTrue(compareEarthQuakeData(0, earthQuakeDataIndex: 0))
        XCTAssertTrue(compareEarthQuakeData(1, earthQuakeDataIndex: 1))
        XCTAssertTrue(compareEarthQuakeData(2, earthQuakeDataIndex: 2))
        XCTAssertTrue(compareEarthQuakeData(3, earthQuakeDataIndex: 3))
        XCTAssertTrue(compareEarthQuakeData(4, earthQuakeDataIndex: 4))
        XCTAssertTrue(compareEarthQuakeData(5, earthQuakeDataIndex: 5))
        XCTAssertTrue(compareEarthQuakeData(6, earthQuakeDataIndex: 6))
        XCTAssertTrue(compareEarthQuakeData(7, earthQuakeDataIndex: 7))
        XCTAssertTrue(compareEarthQuakeData(8, earthQuakeDataIndex: 8))
        XCTAssertTrue(compareEarthQuakeData(9, earthQuakeDataIndex: 9))
    }
    
    func testTableRefresh() {
        
        //delete cell 1
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Tue, 08 Dec 2015 08:46:28"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        //refresh table
        let firstCell = tablesQuery.staticTexts["Tue, 08 Dec 2015 08:27:04"]
        let lastCell = tablesQuery.staticTexts["Sat, 05 Dec 2015 16:56:26"]
        firstCell.pressForDuration(0, thenDragToElement: lastCell)
        
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 11)
        XCTAssertTrue(compareEarthQuakeData(0, earthQuakeDataIndex: 0))
        XCTAssertTrue(compareEarthQuakeData(1, earthQuakeDataIndex: 1))
        XCTAssertTrue(compareEarthQuakeData(2, earthQuakeDataIndex: 2))
        XCTAssertTrue(compareEarthQuakeData(3, earthQuakeDataIndex: 3))
        XCTAssertTrue(compareEarthQuakeData(4, earthQuakeDataIndex: 4))
        XCTAssertTrue(compareEarthQuakeData(5, earthQuakeDataIndex: 5))
        XCTAssertTrue(compareEarthQuakeData(6, earthQuakeDataIndex: 6))
        XCTAssertTrue(compareEarthQuakeData(7, earthQuakeDataIndex: 7))
        XCTAssertTrue(compareEarthQuakeData(8, earthQuakeDataIndex: 8))
        XCTAssertTrue(compareEarthQuakeData(9, earthQuakeDataIndex: 9))
        XCTAssertTrue(compareEarthQuakeData(10, earthQuakeDataIndex: 10))
    }

    
    private func compareEarthQuakeData(cellIndex: UInt, earthQuakeDataIndex: Int) -> Bool {
        
        let cells = XCUIApplication().tables.cells
        return cells.elementBoundByIndex(cellIndex).staticTexts.elementBoundByIndex(0).label == self.getEarthQuakeCellData(earthQuakeDataIndex).label1 && cells.elementBoundByIndex(cellIndex).staticTexts.elementBoundByIndex(1).label == self.getEarthQuakeCellData(earthQuakeDataIndex).label2 && cells.elementBoundByIndex(cellIndex).staticTexts.elementBoundByIndex(2).label == self.getEarthQuakeCellData(earthQuakeDataIndex).label3
    }
    
    private struct earthQuakeCellData {
        
        var label1 = ""
        var label2 = ""
        var label3 = ""
    }
    
    private func getEarthQuakeCellData(index: Int) -> earthQuakeCellData {
        
        var earthQuakeData = earthQuakeCellData()
        
        switch index {
        case 0:
            earthQuakeData.label1 = "4.8 - 143.6 miles WSW of Adak"
            earthQuakeData.label2 = "Tue, 08 Dec 2015 08:46:28"
            earthQuakeData.label3 = "Lat: 51.1139 Lon: -179.76"
        case 1:
            earthQuakeData.label1 = "3.8 - 141.4 miles WSW of Adak"
            earthQuakeData.label2 = "Tue, 08 Dec 2015 08:27:04"
            earthQuakeData.label3 = "Lat: 51.1049 Lon: -179.7"
        case 2:
            earthQuakeData.label1 = "5.7 - ANDREANOF ISLANDS, ALEUTIAN IS., ALASKA"
            earthQuakeData.label2 = "Mon, 07 Dec 2015 11:09:28"
            earthQuakeData.label3 = "Lat: 51.9681 Lon: -179.277"
        case 3:
            earthQuakeData.label1 = "3.91 - 143.5 miles E of Adak"
            earthQuakeData.label2 = "Sun, 06 Dec 2015 15:13:33"
            earthQuakeData.label3 = "Lat: 51.9248 Lon: -173.29"
        case 4:
            earthQuakeData.label1 = "3.5 - OKLAHOMA"
            earthQuakeData.label2 = "Sun, 06 Dec 2015 09:05:40"
            earthQuakeData.label3 = "Lat: 36.2649 Lon: -97.3529"
        case 5:
            earthQuakeData.label1 = "4.3 - 147.5 miles SSE of Dillingham"
            earthQuakeData.label2 = "Sat, 05 Dec 2015 19:30:34"
            earthQuakeData.label3 = "Lat: 57.0457 Lon: -157.003"
        case 6:
            earthQuakeData.label1 = "5.9 - COQUIMBO, CHILE"
            earthQuakeData.label2 = "Sat, 05 Dec 2015 16:56:26"
            earthQuakeData.label3 = "Lat: -30.3093 Lon: -71.5268"
        case 7:
            earthQuakeData.label1 = "5.7 - 110.8 miles W of Adak"
            earthQuakeData.label2 = "Sat, 05 Dec 2015 13:22:26"
            earthQuakeData.label3 = "Lat: 51.6848 Lon: -179.227"
        case 8:
            earthQuakeData.label1 = "3.5 - OKLAHOMA"
            earthQuakeData.label2 = "Sat, 05 Dec 2015 03:53:28"
            earthQuakeData.label3 = "Lat: 36.7341 Lon: -98.125"
        case 9:
            earthQuakeData.label1 = "8.25 - 23.1 miles NE of Vya,NV"
            earthQuakeData.label2 = "Fri, 04 Dec 2015 23:35:47"
            earthQuakeData.label3 = "Lat: 41.8654 Lon: -119.599"
        case 10:
            earthQuakeData.label1 = "5.6 - NEAR THE COAST OF SOUTHERN PERU"
            earthQuakeData.label2 = "Fri, 04 Dec 2015 10:15:25"
            earthQuakeData.label3 = "Lat: -16.2519 Lon: -72.2256"
        default:
            break
        }
        
        return earthQuakeData
    }
}
