//
//  CrimeRate.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class CrimeRate {
    
    static let typeKey = "crime_type"
    static let rateKey = "crime_rate"
    static let countKey = "crime_count"
    static let nameKey = "name"
    static let warningPercentKey = "warningPercent"
    static let userReferenceKey = "userRef"
    static let crimeRateKey = "CrimeRate"
    
    let type: String
    var rate: String
    let count: String
    let name: String
    var userReference: CKReference?
    var cloudKitRecordID: CKRecordID?
    var warningPercent: Int?
    
    init(warningPercent: Int?, userReference: CKReference?) {
        self.warningPercent = warningPercent
        self.userReference = userReference
        self.type = ""
        self.rate = ""
        self.count = ""
        self.name = ""
    }
    
    init?(dictionary: [String: Any]) {
        guard let type = dictionary[CrimeRate.typeKey] as? String,
            let rate = dictionary[CrimeRate.rateKey] as? String,
            let count = dictionary[CrimeRate.countKey] as? String,
            let name = dictionary[CrimeRate.nameKey] as? String else { return nil }
        
        self.type = type
        self.rate = rate
        self.count = count
        self.name = name
    }
    
    init?(cloudKitRecord: CKRecord) {
        self.warningPercent = cloudKitRecord[CrimeRate.warningPercentKey] as? Int
        self.userReference = cloudKitRecord[CrimeRate.userReferenceKey] as? CKReference
        self.type = ""
        self.rate = ""
        self.count = ""
        self.name = ""
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
}

extension CKRecord {
    convenience init(crimeRate: CrimeRate) {
        let recordID = crimeRate.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: CrimeRate.crimeRateKey, recordID: recordID)
        self.setValue(crimeRate.warningPercent, forKey: CrimeRate.warningPercentKey)
        self.setValue(crimeRate.userReference, forKey: CrimeRate.userReferenceKey)
    }
}


