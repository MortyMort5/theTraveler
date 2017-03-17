//
//  TravelLogViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/17/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class TravelLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAllUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchAllUsers()
    }
    
    func fetchAllUsers() {
        UserController.shared.fetchAllUserData { (users) in
            if users.count == 0 {
                print("Nothing was fetched while fetching all users data")
                return
            }
            DispatchQueue.main.async {
                self.users = users
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelLogCell", for: indexPath)
                let user = users[indexPath.row]
                cell.textLabel?.text = user.username
                cell.detailTextLabel?.text = "\(user.states.count-1)"
        return cell
    }
}
