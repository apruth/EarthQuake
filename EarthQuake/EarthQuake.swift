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
    var date: NSDate?
    var dateString = ""
    var title = ""
    var link = ""
    var floorMagnitude = ""
    
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
