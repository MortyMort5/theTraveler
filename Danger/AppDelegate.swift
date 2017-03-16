//
//  AppDelegate.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/8/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        sleep(1)

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
        UserController.shared.subscriptionNotification()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }


}

