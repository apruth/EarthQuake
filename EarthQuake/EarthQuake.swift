//
//  EarthQuake.swift
//  Assignment2
//
//  Created by Aaron Ruth on 6/16/15.
//  Copyright (c) 2015 Aaron Ruth. All rights reserved.
//

import Foundation

/**
* Holds data that we use as makeup of an earthquake
*/
class EarthQuake: Equatable {
    
    var lattitude = ""
    var longitude = ""
    var date: Date?
    var dateString = ""
    var title = ""
    var link = ""
    var floorMagnitude = ""
    
    convenience init(lattitude: String, longitude: String, dateString: String, title: String, link: String, floorMagnitude: String) {
        self.init()
        
        self.lattitude = lattitude
        self.longitude = longitude
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        self.date = dateFormatter.date(from: dateString)
        
        self.dateString = dateString
        self.title = title
        self.link = link
        self.floorMagnitude = floorMagnitude
    }
}

/**
* Equatable protocol function used to compare two earth quakes
*/
func ==(lhs: EarthQuake, rhs: EarthQuake) -> Bool {
    
    return lhs.lattitude == rhs.lattitude &&
        lhs.longitude == rhs.longitude &&
        lhs.date == rhs.date &&
        lhs.dateString == rhs.dateString &&
        lhs.title == rhs.title &&
        lhs.link == rhs.link &&
        lhs.floorMagnitude == rhs.floorMagnitude
}
