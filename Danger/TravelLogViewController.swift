//
//  TravelLogViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/17/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class TravelLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 25.0
        self.fetchAllUsers()
        var screenEdgeRecognizer: UISwipeGestureRecognizer
        screenEdgeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToGoBack))
        screenEdgeRecognizer.direction = .down
        view.addGestureRecognizer(screenEdgeRecognizer)
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
    func swipeToGoBack() {
        dismiss(animated: true, completion: nil)
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

    //==============================================================
    // MARK: - DataSource
    //==============================================================
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "- Users & State Count -"
        label.backgroundColor = UIColor.clear
        label.layer.opacity = 0.7
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "label"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelLogCell", for: indexPath)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
        } else {
            cell.backgroundColor = UIColor.clear
        }
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = "\(user.states.count)"
        return cell
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
}
