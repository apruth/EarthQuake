//
//  EarthQuakeViewController.swift
//  Assignment2
//
//  Created by Aaron Ruth on 6/15/15.
//  Copyright (c) 2015 Aaron Ruth. All rights reserved.
//

import UIKit

/**
* EarthQuakeViewController - View containing UI components that will display and interact with earthquake data and user.
*/
class EarthQuakeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let earthQuakeDays = 30
    private var earthQuakes: [EarthQuake]?
    private var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var earthQuakeTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //establish tableview refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refreshTable:", forControlEvents: UIControlEvents.ValueChanged)
        self.earthQuakeTable.addSubview(self.refreshControl)
        
        //show activity indicator until data is loaded
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidden = false
        
        //load earth quake data
        self.loadEarthQuakeData()
    }
    
    /**
    * Action fired when table view is refreshed
    */
    func refreshTable(sender: AnyObject) {
        
        //reload earthquake data
        loadEarthQuakeData()
        dispatch_async(dispatch_get_main_queue(),{[weak self] in
            if let strongSelf = self {
                strongSelf.refreshControl.endRefreshing()
            }
        })
    }
    
    /**
    * Loads earthquake data through EarthQuakes singleton and updates table view with data
    */
    private func loadEarthQuakeData() {
        
        EarthQuakes.sharedInstance.getEarthQuakeData(earthQuakeDays) { [weak self] (inner) -> () in
            
            if let strongSelf = self {
                do {
                    
                    //try to get earthquake data
                    let earthQuakes = try inner()
                    
                    //load table with earthquake data
                    strongSelf.earthQuakes = earthQuakes
                    dispatch_async(dispatch_get_main_queue(),{ _ in
                        strongSelf.activityIndicator.stopAnimating()
                        strongSelf.earthQuakeTable.reloadData()
                    })
                } catch let error {
                    
                    //catch exception and present error
                    print("Error occurred - \(error)")
                    dispatch_async(dispatch_get_main_queue(),{ _ in
                        strongSelf.showAlertError()
                    })
                }
            }
        }
    }
    
    /**
    * Function used to show an alert view in case an error occurred while retrieving earth quake data
    */
    private func showAlertError() {
        
        let alert = UIAlertController(title: "Error", message: "An error occurred while tyring to retreive earth quake data.  Press button below to try again", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { [weak self](alert: UIAlertAction!)  -> () in
            
            if let strongSelf = self {
                strongSelf.loadEarthQuakeData()
            }
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**)
    * UITableView datasource method for returning the number of sections in a table
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return EarthQuakeViewController.getSectionTotal(0, earthQuakes: self.earthQuakes, previousComponents: nil)
    }
    
    /**
    * UITableView datasource method for returning number of rows in a section
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //construct index path
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), sectionDate = earthQuake.date {
                
            let dateComponentsForSection = EarthQuakeViewController.getDateComponentsForDate(sectionDate)
            return EarthQuakeViewController.getNumberOfRowsForDate(dateComponentsForSection, earthQuakes: self.earthQuakes)
        }
        return 0
    }
    
    /**
    * UITableView datasource method for building table
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tableCell = UITableViewCell()
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes),
            earthQuakeCell = tableView.dequeueReusableCellWithIdentifier("EarthQuakeTableViewCell") as? EarthQuakeTableViewCell {
            
            //set title, longitude, lattitude, and date for cell
            earthQuakeCell.titleLabel.text = earthQuake.title
            earthQuakeCell.latlonLabel.text = "Lat: \(earthQuake.lattitude) Lon: \(earthQuake.longitude)"
                
            if let earthQuakeDate = earthQuake.date {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
                earthQuakeCell.dateLabel.text = dateFormatter.stringFromDate(earthQuakeDate)
            }
                
            let magSevenColor = UIColor(red: CGFloat(255)/255, green: CGFloat(50)/255, blue: CGFloat(30)/255, alpha: 1.0)
            let magFiveColor = UIColor(red: CGFloat(255)/255, green: CGFloat(145)/255, blue: CGFloat(165)/255, alpha: 1.0)
                
            //set background color of cell where appropriate
            if let magnitude = Int(earthQuake.floorMagnitude) {
                if magnitude >= 7 {
                    earthQuakeCell.backgroundColor = magSevenColor
                } else if magnitude >= 5 {
                    earthQuakeCell.backgroundColor = magFiveColor
                } else {
                    earthQuakeCell.backgroundColor = UIColor.whiteColor()
                }
            }

            tableCell = earthQuakeCell
        }
        return tableCell
    }
    
    /**
    * UITableView datasource method for getting header titles
    */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //construct index path
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), sectionDate = earthQuake.date {
                
            let dateComponentsForSection = EarthQuakeViewController.getDateComponentsForDate(sectionDate)
            let monthName: AnyObject = NSDateFormatter().monthSymbols[dateComponentsForSection.month - 1]
                
            return "\(monthName) \(dateComponentsForSection.day)"
        }
        return ""
    }
    
    /**
    * UITableView datasource method indicating that a row can be deleted
    */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /**
    * UITableView datasource method for deleting a table cell
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), earthQuakes = self.earthQuakes {
            
            self.earthQuakes = earthQuakes.filter({$0 != earthQuake})
            self.earthQuakeTable.reloadData()
        }
    }
    
    /**
    * UITableView delegate method indicating that a row has been selected.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), url = NSURL(string: earthQuake.link) {
            
            UIApplication.sharedApplication().openURL(url)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /**
    * Returns the earthquake in earthquakes list for given index path
    *
    * @param indexPath - path used to retrieve earthquake from list
    * @param currentRow - row tally
    * @param currentSection - sectionTally
    * @param earthQuakes - list of earthquakes to query
    *
    * @return - retrieved earthquake
    */
    private class func getEarthQuakeForIndexPath(indexPath: NSIndexPath, currentRow: Int, currentSection: Int, earthQuakes: [EarthQuake]?) -> EarthQuake? {
        
        if let earthQuakes = earthQuakes, firstEarthQuake = earthQuakes.first, rowDate = firstEarthQuake.date {
            
            //base case if sections and rows are equal
            if indexPath.section == currentSection && indexPath.row == currentRow {
                return firstEarthQuake
            }
            
            //get tail of earthquake list
            let tail = Array(earthQuakes.dropFirst())
            
            //advance row
            if indexPath.section == currentSection {
                
                return getEarthQuakeForIndexPath(indexPath, currentRow: currentRow + 1, currentSection: currentSection, earthQuakes: tail)
            }
            
            //advance section
            if let firstTail = tail.first, tailDate = firstTail.date {
                
                //get date components of first and second element
                let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate)
                let tailComponents = EarthQuakeViewController.getDateComponentsForDate(tailDate)
                
                //recurse through list looking for date components of given section
                if tailComponents.month != rowComponents.month || tailComponents.day != rowComponents.day {
                    return getEarthQuakeForIndexPath(indexPath, currentRow: currentRow, currentSection: currentSection + 1, earthQuakes: tail)
                } else {
                    return getEarthQuakeForIndexPath(indexPath, currentRow: currentRow, currentSection: currentSection, earthQuakes: tail)
                }
            }
        }
        return nil
    }
    
    /**
    * Function returns the count of sections in table.  Sections are determined by unique month/day combo
    *
    * @param currentSection - tally of section
    * @param earthQuakes - list of earthquakes to tally against
    * @param previousComponents - the date components of previous row for comparison for last element
    *
    * @return count of sections
    */
    private class func getSectionTotal(currentSection: Int, earthQuakes: [EarthQuake]?, previousComponents: NSDateComponents?) -> Int {
        
        if let earthQuakes = earthQuakes, firstEarthQuake = earthQuakes.first, rowDate = firstEarthQuake.date {
        
            //get date components of first element
            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate)

            //get tail of earthquake list
            let tail = Array(earthQuakes.dropFirst())
            if let firstTail = tail.first, tailDate = firstTail.date {
        
                let tailComponents = EarthQuakeViewController.getDateComponentsForDate(tailDate)
        
                //recurse through list looking for date components of given section
                if tailComponents.month != rowComponents.month || tailComponents.day != rowComponents.day {
                    return getSectionTotal(currentSection + 1, earthQuakes: tail, previousComponents: rowComponents)
                } else {
                    //acccount for last section of length two
                    if tail.count == 1 && tailComponents.month == rowComponents.month && tailComponents.day == rowComponents.day {
                        if let previousComponents = previousComponents where tailComponents.month != previousComponents.month || tailComponents.day != previousComponents.day {
                            return getSectionTotal(currentSection + 1, earthQuakes: tail, previousComponents: rowComponents)
                        }
                    }
                    return getSectionTotal(currentSection, earthQuakes: tail, previousComponents: rowComponents)
                }
            } else {
                
                //see if last (sole) earthquake comprises a new section in and of itself
                if let previousComponents = previousComponents {
                    if (rowComponents.month != previousComponents.month || rowComponents.day != previousComponents.day) {
                        //need to add one because the last element is a new section
                        return currentSection + 1
                    }
                }
                
                //for earth quake lists consisting of only one day we still want a section
                if currentSection == 0 {
                    return currentSection + 1
                }
            }
        }
        return currentSection
    }
    
    /**
    * Processes a list of earthquakes and counts the number of dates at beginning of list are equal
    * to the given date.
    *
    * @param sectionComponents - the date to compare beginning of list to
    * @param earthQuakes - the list of earthquakes that is being examined
    *
    * @return the count of earthquakes at beginning of list that are equal to given date.
    */
    private class func processRowsForSection(sectionComponents: NSDateComponents, earthQuakes: [EarthQuake]?) -> Int {
        
        if let earthQuakes = earthQuakes, firstEarthquake = earthQuakes.first, rowDate = firstEarthquake.date {
            
            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate)

            if rowComponents.month == sectionComponents.month && rowComponents.day == sectionComponents.day {
                let tail = Array(earthQuakes.dropFirst())
                return 1 + processRowsForSection(sectionComponents, earthQuakes: tail)
            } else {
                return 0
            }
        }
        return 0
    }
    
    /**
    * Returns the number of earthquakes reported for the given day.  This represents a section.
    *
    * @param dateForRows - the date to get earthquakes on
    * @param earthQuakes - the list earthquakes to pull from
    *
    * @return the number of earthquakes for a given day.
    */
    private class func getNumberOfRowsForDate(sectionComponents: NSDateComponents, earthQuakes:[EarthQuake]?) -> Int {
        
        if let earthQuakes = earthQuakes, firstEarthquake = earthQuakes.first, rowDate = firstEarthquake.date {

            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate)

            let tail = Array(earthQuakes.dropFirst())
            if rowComponents.month == sectionComponents.month && rowComponents.day == sectionComponents.day {
                return 1 + EarthQuakeViewController.processRowsForSection(sectionComponents, earthQuakes: tail)
            } else {
                return getNumberOfRowsForDate(sectionComponents, earthQuakes: tail)
            }
        }
        return 0
    }
    
    /** 
    * Gets date components for given nsdate
    *
    * @param date - date to retreive date components from
    *
    * @return date components for date
    */
    private class func getDateComponentsForDate(date: NSDate) -> NSDateComponents {
        
        return NSCalendar.currentCalendar().components([.Day, .Month], fromDate: date)
    }
}
