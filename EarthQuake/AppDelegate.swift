//
//  AppDelegate.swift
//  EarthQuake
//
//  Created by Aaron Ruth on 10/7/15.
//  Copyright © 2015 Aaron Ruth. All rights reserved.
//

import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //stub response if configuration is set to on
        if let usesStubs = NSBundle.mainBundle().objectForInfoDictionaryKey("UsesStubs") as? Bool {
            var earthQuakeStub: OHHTTPStubsDescriptor?
            if usesStubs {
                //set up stub to use
                earthQuakeStub = OHHTTPStubs.stubRequestsPassingTest(
                    {$0.URL!.absoluteString == EarthQuakeConstants.quakeURL}
                    ) { _ in
                        return OHHTTPStubsResponse(fileAtPath: OHPathForFile("EarthQuakeStubSuccess.xml", self.dynamicType)!, statusCode:200, headers:["Content-Type":"application/xml"])
                }
            } else {
                if let earthQuakeStub = earthQuakeStub {
                    OHHTTPStubs.removeStub(earthQuakeStub)
                }
            }
        }

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

