//
//  UserController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    let cloudkitManager = CloudKitManager()
    let publicDB = CKContainer.default().publicCloudDatabase
    var users: [User] = []
    var loggedInUser: User?
    
    //==============================================================
    // MARK: - CloudKit for  FUNCTIONS
    //==============================================================
    func fetchAllUserData(completion: @escaping([User]) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error { print("Error: There was an error fetching user's data from cloudKit. Error: \(error.localizedDescription)"); completion([]); return }
            
            guard let records = records else { print("Error: Records is nil, nothing was fetched. "); completion([]); return }
            
            let users = records.flatMap({ User(record: $0) })
            self.users = users
            
            completion(users)
        }
    }
    
    func fetchDataFor(user: User, completion: @escaping(User?) -> Void) {
        guard let userID = user.cloudKitRecordID else { return }
        
        let predicate = NSPredicate(format: "cloudKitRecordID == %@", userID)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error { print("Error: There was an error fetching user's data from cloudKit. Error: \(error.localizedDescription)"); completion(nil); return }
            
            guard let records = records else { print("Error: Records is nil, nothing was fetched. "); completion(nil); return }
            
            let users = records.flatMap({ User(record: $0) })
            
            completion(users[0])
        }
    }
    
    func saveUserData(username: String, email: String, completion: @escaping() -> Void) {
        let user = User(username: username, email: email)
        let record = CKRecord(user: user)
        
        publicDB.save(record) { (returnedRecord, error) in
            if let error = error {
                print("Error: User's data was not saved to cloudKit successfully. Error: \(error.localizedDescription)")
                completion()
            }
            guard let returnedRecord = returnedRecord else { completion(); return }
            self.loggedInUser = User(record: returnedRecord)
            
            print("Saved to cloudKit successfully")
            completion()
        }
    }
    
    func addToUserRecord(warningPercent: Int, completion: @escaping() -> Void) {
        loggedInUser?.warningPercent = warningPercent
        guard let user = loggedInUser else { completion(); return }
        let record = CKRecord(user: user)
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.completionBlock = {
            completion()
        }
        modifyOperation.savePolicy = .changedKeys
        publicDB.add(modifyOperation)
    }
    
    func updateUserRecord(username: String, email: String, completion: @escaping() -> Void) {
        loggedInUser?.username = username
        loggedInUser?.email = email
        guard let user = loggedInUser else { completion(); return }
        let record = CKRecord(user: user)
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.completionBlock = {
            completion()
        }
        modifyOperation.savePolicy = .changedKeys
        publicDB.add(modifyOperation)
    }
    
    func addStateToRecord(state: String, completion: @escaping() -> Void) {
        loggedInUser?.states.append(state)
        guard let user = loggedInUser else { completion(); return }
        let record = CKRecord(user: user)
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.completionBlock = {
            completion()
        }
        modifyOperation.savePolicy = .changedKeys
        publicDB.add(modifyOperation)
    }
    
    //==============================================================
    // MARK: - Subscription FUNCTION
    //==============================================================
    func subscriptionNotification() {
        guard let user = loggedInUser else { return }
        cloudkitManager.subscribeToHighDangerLevel(crimeRate: user.crimeRate[0], user: user, completion: { (error) in
            if let error = error { print("Error with subsribing: \(error.localizedDescription)"); return  }
        })
    }
}




























