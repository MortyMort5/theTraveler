//
//  CrimeRateController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class CrimeRateController {
    
    let baseURL = URL(string: "https://odn.data.socrata.com/resource/rtec-wkeg.json")
    let token = "yWGjbgxxBvaO7xdDxF0AQyYCJ"
    
    let crimeIsAboveSetPercent = Notification.Name("CrimeHasIncreased")
    let publicDB = CKContainer.default().publicCloudDatabase
    var savedCrimeRate: CrimeRate?
    var crimeRates: [CrimeRate] = [] {
        didSet {
            NotificationCenter.default.post(name: self.crimeIsAboveSetPercent, object: self)
        }
    }
    
    static let shared = CrimeRateController()
    
    //==============================================================
    // MARK: - Fetches data from Crime API FUNCTION
    //==============================================================
    func fetchCrimeData(byCurrentLocation location: String, completion: @escaping([CrimeRate]) -> Void) {
        
        guard let url = baseURL else { fatalError("Error with unwrapping the baseURL"); completion([]); return }

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
    
    //==============================================================
    // MARK: - Percent Algorythm FUNCTION
    //==============================================================
    func warningPercentAlgarythm() -> Int {
        var percent = 0.0
        for crime in crimeRates {
            var total = 0.0
            var temp = 0.0
            guard let rate = Double(crime.rate) else { return 0 }
            total += rate
            temp = total * 100000.0
            percent = round(temp)
        }
        return Int(percent)
    }
    
    //==============================================================
    // MARK: - CloudKit Functions
    //==============================================================
    func saveCrimeData(completion: @escaping() -> Void) {
        let records = crimeRates.flatMap({ CKRecord(crimeRate: $0) })
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.completionBlock = {
            completion()
        }
        modifyOperation.savePolicy = .changedKeys
        publicDB.add(modifyOperation)
    }
}





































