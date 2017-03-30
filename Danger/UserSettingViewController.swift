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
        self.updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
        self.updateViews()
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
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        LoadingIndicatorView.show("Updating")
        guard let username = usernameTextField.text, let email = emailTextField.text, !username.isEmpty, !email.isEmpty else { stopUpdating(); return }
        UserController.shared.updateUserRecord(username: username, email: email) { (bool) in
            if bool {
                print("Username is takin already")
                DispatchQueue.main.async {
                    self.timerToStopUpdating()
                    self.usernameTakenAlert()
                }
            }
            DispatchQueue.main.async {
                self.timerToStopUpdating()
            }
        }
    }
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
    func timerToStopUpdating() {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(UserSettingViewController.stopUpdating), userInfo: nil, repeats: false)
    }
    
    func stopUpdating() {
        LoadingIndicatorView.hide()
    }
    
    //==============================================================
    // MARK: - Data Source FUNCTIONS
    //==============================================================
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let username = currentUser?.username else { return ""}
        return "States \(username) has Visited"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stateCount = currentUser?.states.count else { return 0 }
        return stateCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userStateCell", for: indexPath)
        guard let states = currentUser?.states[indexPath.row] else { return cell }
        cell.textLabel?.text = states
        return cell
    }
    
    //==============================================================
    // MARK: - Update Views
    //==============================================================
    func updateViews() {
        DispatchQueue.main.async {
            self.usernameTextField.text = self.currentUser?.username
            self.emailTextField.text = self.currentUser?.email
        }
    }
    
    //==============================================================
    // MARK: - AlertController
    //==============================================================
    func usernameTakenAlert() {
        let alertController = UIAlertController(title: "That username is already taken", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}













