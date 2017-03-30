//
//  TravelLogViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/17/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class TravelLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAllUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchAllUsers()
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var tableView: UITableView!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func questionButtonTapped(_ sender: Any) {
        travelerInfoAlert()
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var users: [User] = []
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
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
    
    //==============================================================
    // MARK: - Alert Functions
    //==============================================================
    func travelerInfoAlert() {
        let alertController = UIAlertController(title: "TRAVELERS:", message: "Is a list of all the users with this app and how many states they have currently traveled to this month. The winner will get a prize at the end of each month. Go out and travel and see the world.", preferredStyle: .actionSheet)
        let travelAction = UIAlertAction(title: "TRAVEL", style: .cancel, handler: nil)
        alertController.addAction(travelAction)
        present(alertController, animated: true, completion: nil)
    }

    
    //==============================================================
    // MARK: - DataSource
    //==============================================================
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Users & State Count"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelLogCell", for: indexPath)
                let user = users[indexPath.row]
                cell.textLabel?.text = user.username
                cell.detailTextLabel?.text = "\(user.states.count)"
        return cell
    }
}
