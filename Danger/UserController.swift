//
//  UserController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    let publicDB = CKContainer.default().publicCloudDatabase
    var users: [User] = []
    let UserIsLoggedIn = Notification.Name("UserIsLoggedIn")
    let CheckingToSeeIfDoneFetchingUser = Notification.Name("CheckingToSeeIfDoneFetchingUser")
    
    var loadingDone: Bool = false {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.CheckingToSeeIfDoneFetchingUser, object: self)
            }
        }
    }
    
    var loggedInUser: User? {
        didSet {
            DispatchQueue.main.async {
                CrimeRateController.shared.currentUser = self.loggedInUser
                NotificationCenter.default.post(name: self.UserIsLoggedIn, object: self)
            }
        }
    }
    
    var userRecordID: CKRecordID? {
        didSet {
            guard let userRecordID = userRecordID else { return }
            self.fetchDataFor(userRecordID: userRecordID) { (user) in
                self.loggedInUser = user
                self.loadingDone = true
            }
        }
    }
    
    init() {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error with fetching currentUsersID. \(error.localizedDescription)")
                self.loadingDone = true
                return
            }
            guard let recordID = recordID else { self.loadingDone = true; return }
            self.userRecordID = recordID
        }
    }
    
    //==============================================================
    // MARK: - CloudKit for  Fetching
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
    
    func fetchDataFor(userRecordID: CKRecordID, completion: @escaping(User?) -> Void) {
        
        let userRef = CKReference(recordID: userRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "userRef == %@", userRef)
        
        self.fetchRecordsWithType("User", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error with fetching records with type User: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let currentUserRecord = records?.first else { completion(nil); return }
            
            let currentUser = User(record: currentUserRecord)
            completion(currentUser)
        }
    }
    
    func fetchRecordsWithType(_ type: String,
                              predicate: NSPredicate = NSPredicate(value: true),
                              recordFetchedBlock: ((_ record: CKRecord) -> Void)?,
                              completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        let perRecordBlock = { (fetchedRecord: CKRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            recordFetchedBlock?(fetchedRecord)
        }
        queryOperation.recordFetchedBlock = perRecordBlock
        
        var queryCompletionBlock: (CKQueryCursor?, Error?) -> Void = { (_, _) in }
        
        queryCompletionBlock = { (queryCursor: CKQueryCursor?, error: Error?) -> Void in
            
            if let queryCursor = queryCursor {
                // there are more results, go fetch them
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = perRecordBlock
                continuedQueryOperation.queryCompletionBlock = queryCompletionBlock
                
                self.publicDB.add(continuedQueryOperation)
                
            } else {
                completion?(fetchedRecords, error)
            }
        }
        queryOperation.queryCompletionBlock = queryCompletionBlock
        
        self.publicDB.add(queryOperation)
    }

    //==============================================================
    // MARK: - Save to CloudKit
    //==============================================================
    func saveUserData(username: String, email: String, completion: @escaping(Bool) -> Void) {
        checkUserNameforDoubles(username: username) { (bool) in
            if bool {
                print("That username is takin already")
                completion(true)
                return
            }
            
            guard let userRecordID = self.userRecordID else { completion(false); return }
            let userRef = CKReference(recordID: userRecordID, action: .deleteSelf)
            let user = User(username: username, email: email, userRef: userRef)
            let record = CKRecord(user: user)
            self.publicDB.save(record) { (returnedRecord, error) in
                if let error = error {
                    print("Error: User's data was not saved to cloudKit successfully. Error: \(error.localizedDescription)")
                    completion(false)
                }
                
                guard let returnedRecord = returnedRecord else { completion(false); return }
                self.loggedInUser = User(record: returnedRecord)
                print("Saved to cloudKit successfully")
                completion(false)
            }
        }
    }
    
    //==============================================================
    // MARK: - Fix this fuction to use a predicate to check for username
    //==============================================================
    func checkUserNameforDoubles(username: String, completion: @escaping(Bool) -> Void) {
        let predicate = NSPredicate(format: "username == %@", username)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error { print("Error: There was an error fetching user's data from cloudKit. Error: \(error.localizedDescription)"); completion(false); return }
            if records?.count == 0 {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    //==============================================================
    // MARK: - Modify record in CloudKit
    //==============================================================
    
    func updateUserRecord(username: String, email: String, warningPercent: Int, completion: @escaping(Bool) -> Void) {
        checkUserNameforDoubles(username: username) { (bool) in
            if username != self.loggedInUser?.username {
                if (bool) {
                    print("Username is Taken already")
                    completion(true)
                    return
                }
            }
            self.loggedInUser?.username = username
            self.loggedInUser?.email = email
            self.loggedInUser?.warningPercent = warningPercent
            guard let user = self.loggedInUser else { completion(false); return }
            let record = CKRecord(user: user)
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            modifyOperation.completionBlock = {
                completion(false)
            }
            modifyOperation.savePolicy = .changedKeys
            self.publicDB.add(modifyOperation)
        }
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
}




























