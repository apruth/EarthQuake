//
//  EarthQuakeViewController.swift
//  Assignment2
//
//  Created by Aaron Ruth on 6/15/15.
//  Copyright (c) 2015 Aaron Ruth. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

/**
* EarthQuakeViewController - View containing UI components that will display and interact with earthquake data and user.
*/
class EarthQuakeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let earthQuakeDays = 30
    private var earthQuakes: [EarthQuake]?
    private var refreshControl: UIRefreshControl!
    private let locationNotificationRecuestIdentifier = "LocationRequest"
    
    @IBOutlet weak var earthQuakeTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove all previously set location notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [locationNotificationRecuestIdentifier])
        
        //establish tableview refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(EarthQuakeViewController.refreshTable(_:)), for: UIControlEvents.valueChanged)
        self.earthQuakeTable.addSubview(self.refreshControl)
        
        //show activity indicator until data is loaded
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        //load earth quake data
        self.loadEarthQuakeData()
    }
    
    /**
    * Action fired when table view is refreshed
    */
    func refreshTable(_ sender: AnyObject) {
        
        //reload earthquake data
        loadEarthQuakeData()
        DispatchQueue.main.async(execute: {[weak self] in
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
                    DispatchQueue.main.async(execute: { _ in
                        strongSelf.activityIndicator.stopAnimating()
                        strongSelf.earthQuakeTable.reloadData()
                    })
                } catch let error {
                    
                    //catch exception and present error
                    print("Error occurred - \(error)")
                    DispatchQueue.main.async(execute: { _ in
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
        
        let alert = UIAlertController(title: "Error", message: "An error occurred while tyring to retreive earth quake data.  Press button below to try again", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { [weak self](alert: UIAlertAction!)  -> () in
            
            if let strongSelf = self {
                strongSelf.loadEarthQuakeData()
            }
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**)
    * UITableView datasource method for returning the number of sections in a table
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return EarthQuakeViewController.getSectionTotal(0, earthQuakes: self.earthQuakes, previousComponents: nil)
    }
    
    /**
    * UITableView datasource method for returning number of rows in a section
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //construct index path
        let indexPath = IndexPath(row: 0, section: section)
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), let sectionDate = earthQuake.date {
                
            let dateComponentsForSection = EarthQuakeViewController.getDateComponentsForDate(sectionDate as Date)
            return EarthQuakeViewController.getNumberOfRowsForDate(dateComponentsForSection, earthQuakes: self.earthQuakes)
        }
        return 0
    }
    
    /**
    * UITableView datasource method for building table
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableCell = UITableViewCell()
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes),
            let earthQuakeCell = tableView.dequeueReusableCell(withIdentifier: "EarthQuakeTableViewCell") as? EarthQuakeTableViewCell {
            
            //set title, longitude, lattitude, and date for cell
            earthQuakeCell.titleLabel.text = earthQuake.title
            earthQuakeCell.latlonLabel.text = "Lat: \(earthQuake.lattitude) Lon: \(earthQuake.longitude)"
                
            if let earthQuakeDate = earthQuake.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
                earthQuakeCell.dateLabel.text = dateFormatter.string(from: earthQuakeDate as Date)
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
                    earthQuakeCell.backgroundColor = UIColor.white
                }
            }

            tableCell = earthQuakeCell
            
            //set location notification
            let content = UNMutableNotificationContent()
            content.title = "EarthQuake!"
            content.subtitle = "Nearby & Recent Earthquake"
            content.body = "An earthquake happened here recently."
            content.sound = UNNotificationSound.default()
            
            let lattitude = CLLocationDegrees(earthQuake.lattitude)!
            let longitude = CLLocationDegrees(earthQuake.longitude)!
            let center = CLLocationCoordinate2DMake(lattitude, longitude)
            let region = CLCircularRegion.init(center: center, radius: 2000.0, identifier: earthQuake.title)
            region.notifyOnEntry = true;
            region.notifyOnExit = false;
            
            let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
            let request = UNNotificationRequest(identifier: locationNotificationRecuestIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        return tableCell
    }
    
    /**
    * UITableView datasource method for getting header titles
    */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //construct index path
        let indexPath = IndexPath(row: 0, section: section)
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), let sectionDate = earthQuake.date {
                
            let dateComponentsForSection = EarthQuakeViewController.getDateComponentsForDate(sectionDate as Date)
            let monthName = DateFormatter().monthSymbols[dateComponentsForSection.month! - 1]
                
            return "\(monthName) \(dateComponentsForSection.day!)"
        }
        return ""
    }
    
    /**
    * UITableView datasource method indicating that a row can be deleted
    */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
    * UITableView datasource method for deleting a table cell
    */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), let earthQuakes = self.earthQuakes {
            
            self.earthQuakes = earthQuakes.filter({$0 != earthQuake})
            self.earthQuakeTable.reloadData()
        }
    }
    
    /**
    * UITableView delegate method indicating that a row has been selected.
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let earthQuake = EarthQuakeViewController.getEarthQuakeForIndexPath(indexPath, currentRow: 0, currentSection: 0, earthQuakes: self.earthQuakes), let url = URL(string: earthQuake.link) {
            
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    private class func getEarthQuakeForIndexPath(_ indexPath: IndexPath, currentRow: Int, currentSection: Int, earthQuakes: [EarthQuake]?) -> EarthQuake? {
        
        if let earthQuakes = earthQuakes, let firstEarthQuake = earthQuakes.first, let rowDate = firstEarthQuake.date {
            
            //base case if sections and rows are equal
            if (indexPath as NSIndexPath).section == currentSection && (indexPath as NSIndexPath).row == currentRow {
                return firstEarthQuake
            }
            
            //get tail of earthquake list
            let tail = Array(earthQuakes.dropFirst())
            
            //advance row
            if (indexPath as NSIndexPath).section == currentSection {
                
                return getEarthQuakeForIndexPath(indexPath, currentRow: currentRow + 1, currentSection: currentSection, earthQuakes: tail)
            }
            
            //advance section
            if let firstTail = tail.first, let tailDate = firstTail.date {
                
                //get date components of first and second element
                let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate as Date)
                let tailComponents = EarthQuakeViewController.getDateComponentsForDate(tailDate as Date)
                
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
    private class func getSectionTotal(_ currentSection: Int, earthQuakes: [EarthQuake]?, previousComponents: DateComponents?) -> Int {
        
        if let earthQuakes = earthQuakes, let firstEarthQuake = earthQuakes.first, let rowDate = firstEarthQuake.date {
        
            //get date components of first element
            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate as Date)

            //get tail of earthquake list
            let tail = Array(earthQuakes.dropFirst())
            if let firstTail = tail.first, let tailDate = firstTail.date {
        
                let tailComponents = EarthQuakeViewController.getDateComponentsForDate(tailDate as Date)
        
                //recurse through list looking for date components of given section
                if tailComponents.month != rowComponents.month || tailComponents.day != rowComponents.day {
                    return getSectionTotal(currentSection + 1, earthQuakes: tail, previousComponents: rowComponents)
                } else {
                    //acccount for last section of length two
                    if tail.count == 1 && tailComponents.month == rowComponents.month && tailComponents.day == rowComponents.day {
                        if let previousComponents = previousComponents , tailComponents.month != previousComponents.month || tailComponents.day != previousComponents.day {
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
    private class func processRowsForSection(_ sectionComponents: DateComponents, earthQuakes: [EarthQuake]?) -> Int {
        
        if let earthQuakes = earthQuakes, let firstEarthquake = earthQuakes.first, let rowDate = firstEarthquake.date {
            
            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate as Date)

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
    private class func getNumberOfRowsForDate(_ sectionComponents: DateComponents, earthQuakes:[EarthQuake]?) -> Int {
        
        if let earthQuakes = earthQuakes, let firstEarthquake = earthQuakes.first, let rowDate = firstEarthquake.date {

            let rowComponents = EarthQuakeViewController.getDateComponentsForDate(rowDate as Date)

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
    private class func getDateComponentsForDate(_ date: Date) -> DateComponents {
        
        return NSCalendar.current.dateComponents([.day, .month], from: date)
    }
}
