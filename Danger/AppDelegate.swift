//
//  AppDelegate.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/8/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Error registering for remote notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //==============================================================
        // MARK: - Put what ever you want your app to do when the user enters your app through the notification
        //==============================================================
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
}

