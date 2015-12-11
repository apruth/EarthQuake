//
//  EarthQuakeManager.swift
//  Assignment2
//
//  Created by Aaron Ruth on 6/15/15.
//  Copyright (c) 2015 Aaron Ruth. All rights reserved.
//

import Foundation
import OHHTTPStubs

enum QuakeError:ErrorType {
    
    case StatusCodeError(code: Int)
    case ParseError
    case ResponseError(error: NSError)
}

/**
* EarthQuakes class that will be responsible for retrieving and processing earthquake data.
* Intended to be used as singleton
*/
class EarthQuakes: NSObject, NSXMLParserDelegate {
    
    static var appStubs = true
    static let quakeURL = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"

    //singleton variable for EarthQuakes
    static let sharedInstance = EarthQuakes()
    private override init() {}

    private var earthQuakes = [EarthQuake]() //earthquake data -- empty by default
    private var earthQuake: EarthQuake? //earthquake that will be added to list
    private var elementName = "" //the current element being parsed
    
    /**
    * Gets earthquake data from RSS feed with completion.
    *
    * @param days - the number of days for which earthquake data should be retrieved
    * @param completion - closure with inner closure that will return results or throw error
    */
    func getEarthQuakeData(days: Int?, completion: ((inner: () throws -> [EarthQuake]?) -> ())) {
        
        //use stubs to collect earth quake data
        if let quakeUrl = NSURL(string: EarthQuakes.quakeURL) where EarthQuakes.appStubs {
            stub(isHost(quakeUrl.host!)) { _ in
                let stubPath = OHPathForFile("EarthQuakeStubSuccess.xml", self.dynamicType)
                return fixture(stubPath!, headers: ["Content-Type":"application/xml"])
            }
        }

        if let url = NSURL(string: EarthQuakes.quakeURL) {
            
            let request = NSURLRequest(URL: url) //request to earthquake data
            let session = NSURLSession.sharedSession()
            
            //send request to get earthquake data asynchronously with completion
            session.dataTaskWithRequest(request, completionHandler: { [weak self] (data, response, error) -> Void in
           
                if let strongSelf = self {
                    
                    //throw error in completion upon error
                    if let error = error {
                       completion(inner: {throw QuakeError.ResponseError(error: error)})
                        return
                    }
                    
                    //check for status error in response and throw error if found
                    if let response = response, httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode < 200 || httpResponse.statusCode > 399 {
                            completion(inner: {throw QuakeError.StatusCodeError(code: httpResponse.statusCode)})
                            return
                        }
                    }
                    
                    //parse earthquake data
                    if let data = data {
                        
                        //reset earthquake list
                        strongSelf.earthQuakes = [EarthQuake]()
                        
                        //setup xml parser and start parse, throw error if parse error occurs
                        let parser = NSXMLParser(data: data)
                        parser.delegate = self
                        if !parser.parse() {
                            completion(inner: {throw QuakeError.ParseError})
                            return
                        }
                        
                        //trim and sort list of earthquakes
                        strongSelf.trimAndSortEarthQuakes(days, order: .OrderedDescending)
                    }
                    //call completion 
                    completion(inner: {return strongSelf.earthQuakes})
                }
            }).resume()
        }
    }
    
    /**
    * Function, with side effectes, trims instance list of earthquakes that only reside within the given number of days
    * from today and sorts them in given order.
    * 
    * @param days - the number of days from today as optional
    * @param order - the order in which to sort earth quake data
    */
    private func trimAndSortEarthQuakes(days: Int?, order: NSComparisonResult) {
        
        if let days = days {
            //gets date given number of days before today and filters list based on it
            let compareDate = NSDate().dateByAddingTimeInterval(Double(60*60*24*(-days)))
            self.earthQuakes = self.earthQuakes.filter({
                $0.date?.compare(compareDate) == .OrderedDescending
            })
        }
        
        //sorts list of earthquakes
        self.earthQuakes.sortInPlace({
            return $0.date?.compare($1.date!) == order
        })
    }
    
    /**
    * NSXMLParser delegate method indicating that parsing has started for an element
    */
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String]) {
        
        switch elementName {
            
            case "item":
                //instantiate earthquake to be added
                self.earthQuake = EarthQuake()
            default:
                self.elementName = elementName
        }
    }
    
    /**
    * NSXMLParser delegate method indicating that parsing has ended for element
    */
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        
        if let earthQuake = self.earthQuake {
            switch elementName {
            
                case "item":
                    //add earthquake to list of earthquakes
                    self.earthQuakes.append(earthQuake)
                case "pubDate":
                    //add nsdate to earthquake with format like "Tue, 16 Jun 2015 09:42:04 +0000"
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                    earthQuake.date = dateFormatter.dateFromString(earthQuake.dateString)
                default:
                    break
            }
        }
    }
    
    /**
    * NSXMLParser delegate method indicating that there were some charachters found in parsing
    */
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if let earthQuake = self.earthQuake {
            switch self.elementName {
            
                case "geo:lat":
                    earthQuake.lattitude += string
                case "geo:long":
                    earthQuake.longitude += string
                case "pubDate":
                    earthQuake.dateString += string
                case "title":
                    earthQuake.title += string
                case "link":
                    earthQuake.link += string
                case "dc:subject":
                    earthQuake.floorMagnitude += string
                default:
                    break
            }
        }
    }
}
