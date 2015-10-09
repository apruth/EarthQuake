//
//  EarthQuakeTests.swift
//  EarthQuakeTests
//
//  Created by Aaron Ruth on 10/7/15.
//  Copyright © 2015 Aaron Ruth. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import EarthQuake

class EarthQuakeTests: XCTestCase {
    
    let quakeURL = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"
    let timeout = NSTimeInterval(3.0)
    
    /**
    * Sets up earth quake tests with stubs before each test is run
    */
    override func setUp() {
        super.setUp()
        
        //set up stub for responses for earthquake data
        if let usesStubs = NSBundle.mainBundle().objectForInfoDictionaryKey("UsesStubs") as? Bool {
            var earthQuakeStub: OHHTTPStubsDescriptor?
            if usesStubs {
                //set up stub to use
                earthQuakeStub = OHHTTPStubs.stubRequestsPassingTest({ $0.URL!.absoluteString == self.quakeURL })
                    { _ in
                        return OHHTTPStubsResponse(fileAtPath: OHPathForFile("EarthQuakeStubSuccess.xml", self.dynamicType)!, statusCode:200, headers:["Content-Type":"application/xml"])
                }
            } else {
                if let earthQuakeStub = earthQuakeStub {
                    OHHTTPStubs.removeStub(earthQuakeStub)
                }
            }
        }
    }
    
    /**
    * Removes stubs after each execution of a test
    */
    override func tearDown() {
        super.tearDown()
        
        //remove all stubs on tear down
        OHHTTPStubs.removeAllStubs()
    }
    
    /**
    * Tests getting earth quake data against stubs.
    */
    func testGetEarthQuakeDataSuccess() {
        
        let trimEarthQuakeDays = 30
        let expectedEarthQuakes = buildEarthQuakeTestList()
        var asynchSuccess: Bool?
        var asynchError: NSError?
        var asynchEarthQuakes: [EarthQuake]?
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Rresponse of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (success, earthQuakes, error) -> () in
            
            responseArrived.fulfill()
            asynchSuccess = success
            asynchError = error
            asynchEarthQuakes = earthQuakes
        }
        
        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(timeout) { _ -> Void in
            
            XCTAssertEqual(asynchSuccess, true)
            XCTAssertNil(asynchError)
            XCTAssertEqual(asynchEarthQuakes!.count, 11)
            
            for x in 0..<asynchEarthQuakes!.count {
                XCTAssertEqual(expectedEarthQuakes[x], asynchEarthQuakes![x])
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    /**
    * Builds list of earth quakes based off of stubbed data for comparison pusposes in test.
    */
    private func buildEarthQuakeTestList() -> [EarthQuake] {
        
        var earthQuakes = [EarthQuake]()
        
        earthQuakes.append(buildEarthQuake("51.1139", longitude: "-179.76", dateString: "Thu, 08 Oct 2015 13:46:28 +0000", title: "4.8 - 143.6 miles WSW of Adak", link: "http://earthquake.usgs.gov/eqcenter/shakemap/ak/shake/11733807/", floorMagnitude: "4"))
        earthQuakes.append(buildEarthQuake("51.1049", longitude: "-179.7", dateString: "Thu, 08 Oct 2015 13:27:04 +0000", title: "3.8 - 141.4 miles WSW of Adak", link: "http://earthquake.usgs.gov/eqcenter/shakemap/ak/shake/11733805/", floorMagnitude: "3"))
        earthQuakes.append(buildEarthQuake("51.9681", longitude: "-179.277", dateString: "Wed, 07 Oct 2015 16:09:28 +0000", title: "5.7 - ANDREANOF ISLANDS, ALEUTIAN IS., ALASKA", link: "http://earthquake.usgs.gov/eqcenter/shakemap/global/shake/10003kgq/", floorMagnitude: "5"))
        earthQuakes.append(buildEarthQuake("51.9248", longitude: "-173.29", dateString: "Tue, 06 Oct 2015 20:13:33 +0000", title: "3.91 - 143.5 miles E of Adak", link: "http://earthquake.usgs.gov/eqcenter/shakemap/ak/shake/11732289/", floorMagnitude: "3"))
        earthQuakes.append(buildEarthQuake("36.2649", longitude: "-97.3529", dateString: "Tue, 06 Oct 2015 14:05:40 +0000", title: "3.5 - OKLAHOMA", link: "http://earthquake.usgs.gov/eqcenter/shakemap/global/shake/10003kp0/", floorMagnitude: "3"))
        earthQuakes.append(buildEarthQuake("57.0457", longitude: "-157.003", dateString: "Tue, 06 Oct 2015 00:30:34 +0000", title: "4.3 - 147.5 miles SSE of Dillingham", link: "http://earthquake.usgs.gov/eqcenter/shakemap/ak/shake/11731794/", floorMagnitude: "4"))
        earthQuakes.append(buildEarthQuake("-30.3093", longitude: "-71.5268", dateString: "Mon, 05 Oct 2015 21:56:26 +0000", title: "5.9 - COQUIMBO, CHILE", link: "http://earthquake.usgs.gov/eqcenter/shakemap/global/shake/10003kg9/", floorMagnitude: "5"))
        earthQuakes.append(buildEarthQuake("51.6848", longitude: "-179.227", dateString: "Mon, 05 Oct 2015 18:22:26 +0000", title: "5.7 - 110.8 miles W of Adak", link: "http://earthquake.usgs.gov/eqcenter/shakemap/ak/shake/11731307/", floorMagnitude: "5"))
        earthQuakes.append(buildEarthQuake("36.7341", longitude: "-98.125", dateString: "Mon, 05 Oct 2015 08:53:28 +0000", title: "3.5 - OKLAHOMA", link: "http://earthquake.usgs.gov/eqcenter/shakemap/global/shake/10003kcc/", floorMagnitude: "3"))
        earthQuakes.append(buildEarthQuake("41.8654", longitude: "-119.599", dateString: "Mon, 05 Oct 2015 04:35:47 +0000", title: "3.25 - 23.1 miles NE of Vya,NV", link: "http://earthquake.usgs.gov/eqcenter/shakemap/nn/shake/00513400/", floorMagnitude: "3"))
        earthQuakes.append(buildEarthQuake("-16.2519", longitude: "-72.2256", dateString: "Sun, 04 Oct 2015 15:15:25 +0000", title: "5.6 - NEAR THE COAST OF SOUTHERN PERU", link: "http://earthquake.usgs.gov/eqcenter/shakemap/global/shake/10003k7q/", floorMagnitude: "5"))
        
        return earthQuakes
    }
    
    /**
    * Build an earthquake based on given inputs
    */
    private func buildEarthQuake(lattitude: String, longitude: String, dateString: String, title: String, link: String, floorMagnitude: String) -> EarthQuake {
        
        let earthQuake = EarthQuake()
        earthQuake.lattitude = lattitude
        earthQuake.longitude = longitude
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        earthQuake.date = dateFormatter.dateFromString(dateString)
        
        earthQuake.dateString = dateString
        earthQuake.title = title
        earthQuake.link = link
        earthQuake.floorMagnitude = floorMagnitude
        
        return earthQuake
    }
}
