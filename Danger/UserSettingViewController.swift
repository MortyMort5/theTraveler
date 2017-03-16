//
//  UserSettingViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/16/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class UserSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        userStatesTableView.delegate = self
        userStatesTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentUser = UserController.shared.loggedInUser
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User?
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var userStatesTableView: UITableView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, let email = emailTextField.text, !username.isEmpty, !email.isEmpty else { return }
        UserController.shared.updateUserRecord(username: username, email: email) {
            
        }
    }
    
    //==============================================================
    // MARK: - Data Source FUNCTIONS
    //==============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentUser?.states.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let states = currentUser?.states[indexPath.row]
        cell.textLabel?.text = states
        
        return cell
    }
}
