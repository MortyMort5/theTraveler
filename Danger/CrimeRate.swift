//
//  CrimeRate.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class CrimeRate {
    
    private let typeKey = "crime_type"
    private let rateKey = "crime_rate"
    private let countKey = "crime_count"
    private let nameKey = "name"
    private let userReferenceKey = "userReference"
    
    let type: String
    var rate: String
    let count: String
    let name: String
    var userReference: CKReference?
    var cloudKitRecordID: CKRecordID?
    var warningPercent: Int {
        return CrimeRateController.shared.warningPercentAlgarythm()
    }
    
    init(type: String, rate: String, count: String, name: String) {
        self.type = type
        self.rate = rate
        self.count = count
        self.name = name
    }
    
    init?(dictionary: [String: Any]) {
        guard let type = dictionary[typeKey] as? String,
            let rate = dictionary[rateKey] as? String,
            let count = dictionary[countKey] as? String,
            let name = dictionary[nameKey] as? String else { return nil }
        
        self.type = type
        self.rate = rate
        self.count = count
        self.name = name
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let type = cloudKitRecord[typeKey] as? String,
            let rate = cloudKitRecord[rateKey] as? String,
            let count = cloudKitRecord[countKey] as? String,
            let name = cloudKitRecord[nameKey] as? String else { return nil }
        
        self.type = type
        self.rate = rate
        self.count = count
        self.name = name
        self.userReference = cloudKitRecord[userReferenceKey] as? CKReference
    }
}

extension CKRecord {
    convenience init(crimeRate: CrimeRate) {
        let recordID = crimeRate.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "CrimeRate", recordID: recordID)
        self.setValue(crimeRate.count, forKey: "count")
        self.setValue(crimeRate.type, forKey: "type")
        self.setValue(crimeRate.rate, forKey: "rate")
        self.setValue(crimeRate.name, forKey: "name")
        self.setValue(crimeRate.userReference, forKey: "userReference")
    }
}


