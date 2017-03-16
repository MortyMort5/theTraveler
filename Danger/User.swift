//
//  User.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    var username: String
    var email: String
    var states: [String]
    var cloudKitRecordID: CKRecordID?
    var warningPercent: Int?
    var crimeRate: [CrimeRate]
    
    init(username: String, email: String, states: [String] = [""], warningPercent: Int = 0, crimeRate: [CrimeRate] = []) {
        self.username = username
        self.email = email
        self.states = states
        self.warningPercent = warningPercent
        self.crimeRate = crimeRate
    }
    
    init?(record: CKRecord) {
        guard let username = record["username"] as? String,
            let email = record["email"] as? String,
            let states = record["states"] as? [String],
            let warningPercent = record["warningPercent"] as? Int else { return nil }
        self.username = username
        self.email = email
        self.states = states
        self.warningPercent = warningPercent
        self.crimeRate = []
        self.cloudKitRecordID = record.recordID
    }
}

extension CKRecord {
    convenience init(user: User) {
        let recordID = user.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "User", recordID: recordID)
        self.setValue(user.username, forKey: "username")
        self.setValue(user.email, forKey: "email")
        self.setValue(user.states, forKey: "states")
        self.setValue(user.warningPercent, forKey: "warningPercent")
    }
}
