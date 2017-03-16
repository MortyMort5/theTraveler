//
//  CloudKitManager.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/15/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func subscribeToHighDangerLevel(crimeRate: CrimeRate, user: User, completion: @escaping(Error?) -> Void) {
        guard let recordID = crimeRate.cloudKitRecordID, let warningPercent = user.warningPercent else { print("Error with urwrapping users recordID or users warning percent"); completion(nil); return }
        let matchingRecordIDPredicate = NSPredicate(format: "RecordID == %@", recordID)
        let warningPercentPredicate = NSPredicate(format: "crime_rate >= %@ ", warningPercent)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchingRecordIDPredicate, warningPercentPredicate])
        let subscription = CKQuerySubscription(recordType: "CrimeRate", predicate: compoundPredicate, options: .firesOnRecordUpdate)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Your percent of dying right now is \(user.crimeRate[0].warningPercent)."
        subscription.notificationInfo = notificationInfo
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                NSLog("Error with saving subscription. Error: \(error.localizedDescription)")
                completion(nil)
            }
            completion(error)
        }
    }
}
