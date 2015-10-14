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
    
    let timeout = NSTimeInterval(3.0)

    override func setUp() {
        super.setUp()
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
    * Tests getting earth quake for EarthQuakes data against stubs with 30 days of expected data.
    */
    func testGetEarthQuakeDataSuccessAt30() {
        
        //set up stub to use
        stub(isHost(EarthQuakes.quakeURL), response: fixture("EarthQuakeStubSuccess.xml"))
        
        let trimEarthQuakeDays = 30
        let expectedEarthQuakes = buildEarthQuakeExpectedList()
        var asynchEarthQuakes: [EarthQuake]?
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Response of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (inner) -> () in
            
            responseArrived.fulfill()
            do {
                asynchEarthQuakes = try inner()
            } catch _ {
                //fail test
                XCTAssertFalse(true)
            }
        }
        
        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(timeout) { _ -> Void in
            
            //test assertions
            XCTAssertEqual(asynchEarthQuakes!.count, 11)
            
            for x in 0..<asynchEarthQuakes!.count {
                XCTAssertEqual(expectedEarthQuakes[x], asynchEarthQuakes![x])
            }
        }
    }
    
    /**
    * Tests getting earth quake for EarthQuakes data against stubs with 365 days of expected data.
    */
    func testGetEarthQuakeDataSuccessAt365() {
        
        //set up stub to use
        stub(isHost(EarthQuakes.quakeURL), response: fixture("EarthQuakeStubSuccess.xml"))
        
        let trimEarthQuakeDays = 365
        let expectedEarthQuakes = buildEarthQuakeExpectedList()
        var asynchEarthQuakes: [EarthQuake]?
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Response of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (inner) -> () in
            
            responseArrived.fulfill()
            do {
                asynchEarthQuakes = try inner()
            } catch _ { }
        }
        
        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(timeout) { _ -> Void in
            
            //test assertions
            XCTAssertEqual(asynchEarthQuakes!.count, 12)
            
            for x in 0..<asynchEarthQuakes!.count {
                XCTAssertEqual(expectedEarthQuakes[x], asynchEarthQuakes![x])
            }
        }
    }

    /**
    * Tests getting earth quake for EarthQuakes data against stubs with parse error.
    */
    func testGetEarthQuakeDataParseError() {
        
        //set up stub to use
        stub(isHost(EarthQuakes.quakeURL), response: fixture("EarthQuakeStubInvalidXML.xml"))
        
        let trimEarthQuakeDays = 30
        var asynchEarthQuakes: [EarthQuake]?
        var asyncErrorOccurred = false
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Response of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (inner) -> () in
            
            responseArrived.fulfill()
            do {
                asynchEarthQuakes = try inner()
            } catch QuakeError.ParseError {
                asyncErrorOccurred = true
            } catch _ { }
        }
        
        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(self.timeout) { _ -> Void in
            
            //test assertions
            XCTAssertTrue(asyncErrorOccurred)
            XCTAssertNil(asynchEarthQuakes)
        }
    }
    
    /**
    * Tests getting earth quake data and errored status code.
    */
    func testGetEarthQuakeDataError() {
        
        //set up stub to use
        stub(isHost(EarthQuakes.quakeURL), response: fixture(NSData(), status: 400))
        
        let trimEarthQuakeDays = 30
        var asynchErrorCode: Int?
        var asynchEarthQuakes: [EarthQuake]?
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Response of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (inner) -> () in
            
            responseArrived.fulfill()
            do {
                asynchEarthQuakes = try inner()
            } catch QuakeError.StatusCodeError(let code) {
                asynchErrorCode = code
            } catch _ { }
        }

        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(timeout) { _ -> Void in
            
            //test assertions
            XCTAssertEqual(asynchErrorCode, 400)
            XCTAssertNil(asynchEarthQuakes)
        }
    }
    
    /**
    * Tests getting earth quake data when network isnt available
    */
    func testGetEarthQuakeNetworkDown() {
        
        let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue), userInfo:nil)
        //set up stub to use
        stub(isHost(EarthQuakes.quakeURL), response: fixture(notConnectedError))
        
        let trimEarthQuakeDays = 30
        var asynchError: NSError?
        var asynchEarthQuakes: [EarthQuake]?
        
        //get earth quake data
        let responseArrived = self.expectationWithDescription("Response of async request has arrived.")
        EarthQuakes.sharedInstance.getEarthQuakeData(trimEarthQuakeDays) { (inner) -> () in
            
            responseArrived.fulfill()
            do {
                asynchEarthQuakes = try inner()
            } catch QuakeError.ResponseError(let error) {
                asynchError = error
            } catch _ { }
        }

        //wait for asynchronous call to complete before running assertions
        self.waitForExpectationsWithTimeout(timeout) { _ -> Void in

            //test assertions
            XCTAssertNil(asynchEarthQuakes)
            XCTAssertEqual(asynchError!.code, -1009)
        }
    }
    
    //performance test ... future use (additionally OHTTPS allows for setting request/response and download times)
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    /**
    * Builds expected list of earthquakes in sorted order.
    */
    private func buildEarthQuakeExpectedList() -> [EarthQuake] {
        
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
        earthQuakes.append(buildEarthQuake("41.8654", longitude: "-119.599", dateString: "Mon, 05 Apr 2015 04:35:47 +0000", title: "3.25 - 23.1 miles NE of Vya,NV", link: "http://earthquake.usgs.gov/eqcenter/shakemap/nn/shake/00513400/", floorMagnitude: "3"))
        
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
    
    /**
    * Helper function which tests host URL request to see if it is contained in given host.
    */
    private func isHost(host: String) -> (NSURLRequest -> Bool) {
        return { req in req.URL?.absoluteString == host }
    }
    
    /**
    * Helper function which returns stubbed response for given file
    */
    private func fixture(filename: String, status: Int32 = 200) -> (NSURLRequest -> OHHTTPStubsResponse) {
        let filePath = OHPathForFile(filename, self.dynamicType)
        return { _ in OHHTTPStubsResponse(fileAtPath: filePath!, statusCode: status, headers: ["Content-Type":"application/xml"]) }
    }
    
    /**
    * Helper function which returns stubbed response for given data
    */
    private func fixture(data: NSData, status: Int32 = 200) -> (NSURLRequest -> OHHTTPStubsResponse) {
        return { _ in OHHTTPStubsResponse(data: data, statusCode: status, headers: ["Content-Type":"application/xml"]) }
    }
    
    /**
    * Helper function which returns stubbed response for given error
    */
    private func fixture(error: NSError) -> (NSURLRequest -> OHHTTPStubsResponse) {
        return { _ in  return OHHTTPStubsResponse(error: error) }
    }
    
    /**
    * Helper function that takes a request and response and sets up stub.
    */
    private func stub(condition: NSURLRequest -> Bool, response: NSURLRequest -> OHHTTPStubsResponse) {
        OHHTTPStubs.stubRequestsPassingTest({ condition($0) }, withStubResponse: response)
    }
}
