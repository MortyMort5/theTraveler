//
//  CrimeRateController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class CrimeRateController {
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    let baseURL = URL(string: "https://odn.data.socrata.com/resource/rtec-wkeg.json")
    let token = "yWGjbgxxBvaO7xdDxF0AQyYCJ"
    let checkWarningPercent = Notification.Name("checkWarningPercent")
    let publicDB = CKContainer.default().publicCloudDatabase
    var largerWarningPercent: Int = 0
    var savedCrimeRate: CrimeRate?
    var currentUser: User?
    var curLocation: String?
    var searchedLocation: String?
    var warningPercentComparison: Int = 1000
    static let shared = CrimeRateController()
    var warningPercent: Int = 0
    var searchedCrimeRate: [CrimeRate] = []
    var crimeRates: [CrimeRate] = [] {
        didSet {
            self.warningPercentAlgarythm()
            if warningPercent != warningPercentComparison && self.currentUser != nil {
                self.warningPercentComparison = self.warningPercent
                fetchWarningPercent(completion: { (crimeRate) in
                    print("Hit Fetch Function")
                    if crimeRate == nil {
                        self.saveWarningPercent {
                            print("Hit Save Function")
                        }
                    } else {
                        self.modifyWarningPercent {
                            print("Hit Modify Function")
                        }
                    }
                })
            }
        }
    }

    //==============================================================
    // MARK: - Fetches data from Crime API FUNCTION
    //==============================================================
    func fetchCrimeData(byCurrentLocation location: String, completion: @escaping([CrimeRate]) -> Void) {
        self.curLocation = location
        guard let url = baseURL else { fatalError("Error with unwrapping the baseURL") }

        let urlParameters = ["name": location, "$$app_token": token]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters, body: nil) { (data, error) in
            
            if let error = error { print("Error with fetching data from url with error: \(error.localizedDescription)"); completion([]); return }
            
            guard let data = data,
                let responseStringData = String(data: data, encoding: .utf8) else { print("Error with converting data into a string"); completion([]); return }
            
            guard let array = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [[String: Any]] else { print("Error with serializing data \(responseStringData)"); completion([]); return }
            
            let crimeRates = array.flatMap({ CrimeRate(dictionary: $0) })
            self.crimeRates = crimeRates
            completion(crimeRates)
        }
    }
    
    func searchedCrimeData(byCurrentLocation location: String, completion: @escaping([CrimeRate]) -> Void) {
        self.searchedLocation = location
        guard let url = baseURL else { fatalError("Error with unwrapping the baseURL") }
        
        let urlParameters = ["name": location, "$$app_token": token]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters, body: nil) { (data, error) in
            
            if let error = error { print("Error with fetching data from url with error: \(error.localizedDescription)"); completion([]); return }
            
            guard let data = data,
                let responseStringData = String(data: data, encoding: .utf8) else { print("Error with converting data into a string"); completion([]); return }
            
            guard let array = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [[String: Any]] else { print("Error with serializing data \(responseStringData)"); completion([]); return }
            
            let crimeRates = array.flatMap({ CrimeRate(dictionary: $0) })
            self.searchedCrimeRate = crimeRates
            completion(crimeRates)
        }
    }
    
    //==============================================================
    // MARK: - Warning Percent
    //==============================================================
    func warningPercentAlgarythm() {
//        population = crimeRate / crimeCount
//        dangerLVL = population / crimeCount
        var violentCrime: CrimeRate?
        for crimeRate in crimeRates {
            if crimeRate.type == "Violent crime" {
                violentCrime = crimeRate
            }
        }
        let rateStringOpt = violentCrime?.rate
        guard let rateString = rateStringOpt else { return }
        guard let rate = Double(rateString) else { return }
        let doubleVal = rate * 1000
        let percent = Int(doubleVal)
        self.warningPercent = percent
    }
    
    func searchedWarningPercent(crimeRates: [CrimeRate]) -> Int {
        var violentCrime: CrimeRate?
        for crimeRate in crimeRates {
            if crimeRate.type == "Violent crime" {
                violentCrime = crimeRate
            }
        }
        let rateStringOpt = violentCrime?.rate
        guard let rateString = rateStringOpt else { return 0 }
        guard let rate = Double(rateString) else { return 0 }
        let doubleVal = rate * 1000
        let percent = Int(doubleVal)
        return percent
    }
    
    //==============================================================
    // MARK: - CloudKit
    //==============================================================
    func saveWarningPercent(completion: @escaping() -> Void) {
        guard let currUserID = currentUser?.cloudKitRecordID else { completion(); return }
        let userRef = CKReference(recordID: currUserID, action: .deleteSelf)
        let crimeRate = CrimeRate(warningPercent: self.warningPercent, userReference: userRef)
        let record = CKRecord(crimeRate: crimeRate)
        self.publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error saving crimeRate WarningPercent: \(error)")
                completion()
                return
            } else {
                guard let returnedRecord = record else { completion(); return }
                self.savedCrimeRate = CrimeRate(cloudKitRecord: returnedRecord)
                print("Saved")
                completion()
            }
        }
    }
    
    func modifyWarningPercent(completion: @escaping() -> Void) {
        savedCrimeRate?.warningPercent = warningPercent
        guard let modifiedCrimeRate = savedCrimeRate else { completion(); return }
        let record = CKRecord(crimeRate: modifiedCrimeRate)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.completionBlock = {
            print("Modified")
            completion()
        }
        operation.savePolicy = .changedKeys
        publicDB.add(operation)
    }
    
    func fetchWarningPercent(completion: @escaping(CrimeRate?) -> Void) {
        guard let userID = currentUser?.cloudKitRecordID else { return }
        let userRef = CKReference(recordID: userID, action: .deleteSelf)
        let predicate = NSPredicate(format: "userRef == %@", userRef)
        let query = CKQuery(recordType: CrimeRate.crimeRateKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error with fetching CrimeRates: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = records else { completion(nil); return }
            let crimeRates = records.flatMap({ CrimeRate(cloudKitRecord: $0) })
            self.savedCrimeRate = crimeRates.first
            print("Fetched")
            completion(crimeRates.first)
        }
    }
    
    //==============================================================
    // MARK: - Subscription FUNCTION
    //==============================================================
    func subscribeToHighDangerLevel(completion: @escaping(Error?) -> Void) {
        guard let userRecordID = self.currentUser?.cloudKitRecordID, let userWarningPercent = currentUser?.warningPercent else { print("Error with urwrapping users recordID or users warning percent"); completion(nil); return }
        let userRef = CKReference(recordID: userRecordID, action: .deleteSelf)
        let matchingRecordIDPredicate = NSPredicate(format: "userRef == %@", userRef)
        let warningPercentPredicate = NSPredicate(format: "warningPercent >= %d", userWarningPercent)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchingRecordIDPredicate, warningPercentPredicate])
        let subscription = CKQuerySubscription(recordType: "CrimeRate", predicate: compoundPredicate, options: .firesOnRecordUpdate)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Your danger level is at: \(CrimeRate.warningPercentKey)"
        subscription.notificationInfo = notificationInfo
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                NSLog("Error with saving subscription. Error: \(error.localizedDescription)")
                completion(nil)
            }
            print("Subscribed")
            completion(error)
        }
    }
}






































