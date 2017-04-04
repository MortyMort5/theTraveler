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
    static var shared = AppDelegate()
    var registeredForRemoteNotifications:Bool {
        return UserDefaults.standard.bool(forKey: "registeredForRemoteNotifications")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        sleep(2)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            if let error = error {
                print("Notification authorization failed, or was denied \(error.localizedDescription)")
            } else {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MainViewController.shared.alwaysTrackCurrLocatinAlert()
        UserDefaults.standard.set(true, forKey: "registeredForRemoteNotifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         UserDefaults.standard.set(false, forKey: "registeredForRemoteNotifications")
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

