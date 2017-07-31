//
//  AppDelegate.swift
//  EarthQuake
//
//  Created by Aaron Ruth on 10/7/15.
//  Copyright © 2015 Aaron Ruth. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.delegate = self
        
        //Prompt for location permission
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        self.locationManager.startUpdatingLocation()
        
        UNUserNotificationCenter.current().delegate = self

        //Prompt for notificaiton permission
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted, error) in
                if granted {
                    
                    //set monday, wednesday, friday notification at 9:00
                    let content = UNMutableNotificationContent()
                    content.title = "EarthQuake!"
                    content.subtitle = "Check Out Today's Earthquakes."
                    content.body = "View earth quake info from the last 30 days."
                    content.sound = UNNotificationSound.default()
                    
                    let hour = 9
                    
                    //set monday
                    var monday = DateComponents()
                    monday.hour = hour
                    monday.weekday = 2
                    let mondayTrigger = UNCalendarNotificationTrigger.init(dateMatching: monday, repeats: true)
                    let mondayRequest = UNNotificationRequest(identifier: "EarthQuakeCalendar", content: content, trigger: mondayTrigger)
                    
                    //set wednesday
                    var wednesday = DateComponents()
                    wednesday.hour = hour
                    wednesday.weekday = 4
                    let wednesdayTrigger = UNCalendarNotificationTrigger.init(dateMatching: wednesday, repeats: true)
                    let wednesdayRequest = UNNotificationRequest(identifier: "EarthQuakeCalendar", content: content, trigger: wednesdayTrigger)
                    
                    //set friday
                    var friday = DateComponents()
                    friday.hour = hour
                    friday.weekday = 6
                    let fridayTrigger = UNCalendarNotificationTrigger.init(dateMatching: friday, repeats: true)
                    let fridayRequest = UNNotificationRequest(identifier: "EarthQuakeCalendar", content: content, trigger: fridayTrigger)
                    
                    UNUserNotificationCenter.current().add(mondayRequest)
                    UNUserNotificationCenter.current().add(wednesdayRequest)
                    UNUserNotificationCenter.current().add(fridayRequest)
                }
            }
        )
        
        //set notification indicating new data
        let content = UNMutableNotificationContent()
        content.title = "New EarthQuake Detected"
        content.body = "Check the EarthQuakes! app to see new earth quake."
        content.sound = UNNotificationSound.default()
        
        let image = UIImage(named: "earthquake")
        let imageData = UIImagePNGRepresentation(image!)
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        let imageURL = documentsURL.appendingPathComponent("earthquake.png")
        _ = try? imageData?.write(to: imageURL)
        let attachment =  try? UNNotificationAttachment(identifier: "earthquakeImage", url: imageURL, options: [:])
        
        if let attachment = attachment {
            content.attachments.append(attachment)
        }
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest.init(identifier: "TimeInterval", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        var earthQuakes = EarthQuakes.sharedInstance.earthQuakes
        EarthQuakes.sharedInstance.getEarthQuakeData(30, completion: { (inner) -> () in
            
            var new = false
            if earthQuakes.count > 0 && EarthQuakes.sharedInstance.earthQuakes.count > 0 {
                if earthQuakes[0] != EarthQuakes.sharedInstance.earthQuakes[0] {
                    new = true
                }
            }
            
            if new {
                
                //set notification indicating new data
                let content = UNMutableNotificationContent()
                content.title = "New EarthQuake Detected"
                content.body = "Check the EarthQuakes! app to see new earth quake."
                content.sound = UNNotificationSound.default()
        
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0, repeats: false)
                let request = UNNotificationRequest.init(identifier: "TimeInterval", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler( [.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

