//
//  EarthQuakeManager.swift
//  Assignment2
//
//  Created by Aaron Ruth on 6/15/15.
//  Copyright (c) 2015 Aaron Ruth. All rights reserved.
//

import Foundation
import OHHTTPStubs

/**
* EarthQuakeManager class that will be responsible for retrieving and processing earthquake data.
* Intended to be used as singleton
*/
class EarthQuakes: NSObject, NSXMLParserDelegate {
    
    let quakeURL = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"

    //singleton variable for EarthQuakeManager
    static let sharedInstance = EarthQuakes()
    private override init() {}

    private var earthQuakes = [EarthQuake]() //earthquake data
    private var success = true //success of data retrieval
    private var error: NSError? //error that may have occurred
    private var earthQuake:EarthQuake? //earthquake that will be added to list
    private var elementName = "" //the current element being parsed
    
    /**
    * Gets earthquake data from RSS feed with completion.
    *
    * @param days - the number of days for which earthquake data should be retrieved
    * @param completion - completion handler that will report back earthquake data
    *       success of call and possible error
    */
    func getEarthQuakeData(days: Int?, completion: ((success:Bool, earthQuakes: [EarthQuake], error:NSError?) -> ())) {

        if let url = NSURL(string: quakeURL) {
            
            let request = NSURLRequest(URL: url) //request to earthquake data
            let session = NSURLSession.sharedSession()
            
            //send request to get earthquake data asynchronously with completion
            session.dataTaskWithRequest(request, completionHandler: { [weak self] (data, response, error) -> Void in
           
                if let strongSelf = self {
                    
                    //check for error
                    strongSelf.error = error
                    if error != nil {
                        strongSelf.success = false
                    }
                    
                    //parse response for error
                    if let response = response {
                        strongSelf.success = EarthQuakes.parseResponse(response)
                    }
                    
                    //parse earthquake data
                    if let data = data {
                        
                        //reset earthquake list
                        strongSelf.earthQuakes = [EarthQuake]()
                        
                        //setup xml parser and start parse
                        let parser = NSXMLParser(data: data)
                        parser.delegate = self
                        if !parser.parse() {
                            strongSelf.success = false
                        }
                        
                        //trim and sort list of earthquakes
                        strongSelf.trimEarthQuakesByDays(days)
                    }
                    //call completion 
                    completion(success: strongSelf.success, earthQuakes: strongSelf.earthQuakes, error: strongSelf.error)
                }
            }).resume()
        }
    }
    
    /**
    * Trims list of earthquakes that only reside within the given number of days from today and sorts them
    * 
    * @param days - the number of days from today as optional
    */
    private func trimEarthQuakesByDays(days: Int?) {
        
        if let days = days {
            //gets date given number of days before today and filters list based on it
            let compareDate = NSDate().dateByAddingTimeInterval(Double(60*60*24*(-days)))
            self.earthQuakes = self.earthQuakes.filter({$0.date?.compare(compareDate) == .OrderedDescending})
        }
        
        //sorts list of earthquakes
        self.earthQuakes.sortInPlace({
            return $0.date?.compare($1.date!) == .OrderedDescending
        })
    }
    
    /**
    * Gets status code from repsonse and checks for error
    *
    * @param resposne - response object to parse
    *
    * @return the success nature of status code in response
    */
    private class func parseResponse(response: NSURLResponse) -> Bool {
        
        if let httpResponse = response as? NSHTTPURLResponse {
            
            if httpResponse.statusCode < 200 || httpResponse.statusCode > 399 {
                return false
            }
        }
        return true
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
    
    /**
    * NSXMLParser delegate method indicating that an error occurred while parsing
    */
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        
        self.success = false
        self.error = parseError
    }
}
