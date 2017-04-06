//
//  UserSettingViewController.swift
//  ITravels
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
        self.userStatesTableView.rowHeight = 25.0
        self.updateViews()
        updateViewOnButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
        self.updateViews()
        currentUser = UserController.shared.loggedInUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.warningPercentInfoAlert()
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User?
    var warningPercent: Int = 0
    var warningPercentInfo:Bool {
        return UserDefaults.standard.bool(forKey: "warningPercentInfo")
    }

    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var userStatesTableView: UITableView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var warningPercentTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func updateButtonTapped(_ sender: Any) {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        warningPercentTextField.resignFirstResponder()
        LoadingIndicatorView.show("Updating")
        guard let username = usernameTextField.text, let email = emailTextField.text, let warningPercentString = warningPercentTextField.text, !username.isEmpty, !email.isEmpty else { stopUpdating(); return }
        
        validateInt(warningString: warningPercentString)
        
        UserController.shared.updateUserRecord(username: username, email: email, warningPercent: warningPercent) { (bool) in
            if bool {
                print("Username is takin already")
                DispatchQueue.main.async {
                    self.stopUpdating()
                    self.usernameTakenAlert()
                }
            }
            DispatchQueue.main.async {
                self.timerToStopUpdating()
                self.updateViews()
                CrimeRateController.shared.subscribeToHighDangerLevel(completion: { (error) in
                    if error != nil {
                        print("Error with the subscription")
                    }
                })
            }
        }
    }
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
    func updateViews() {
        DispatchQueue.main.async {
            self.usernameTextField.text = self.currentUser?.username
            self.emailTextField.text = self.currentUser?.email
            self.warningPercentTextField.text = "\(self.currentUser?.warningPercent ?? 0)%"
        }
    }
    
    func updateViewOnButtons() {
        self.updateButton.layer.cornerRadius = 5
        self.updateButton.layer.borderWidth = 1
        self.updateButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    func timerToStopUpdating() {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(UserSettingViewController.stopUpdating), userInfo: nil, repeats: false)
    }
    
    func stopUpdating() {
        LoadingIndicatorView.hide()
    }
    
    func validateInt(warningString: String) {
        if warningString.contains("%") {
            var strArr = warningString.characters.map{ String($0) }
            let _ = strArr.removeLast()
            let joinedInt = strArr.joined(separator: "")
            guard let warningPercentOptional = Int(joinedInt) else { self.stopUpdating(); return }
            warningPercent = warningPercentOptional
        } else {
            guard let warningPercentOptional = Int(warningString) else { self.stopUpdating(); return }
            warningPercent = warningPercentOptional
        }
    }
    
    //==============================================================
    // MARK: - Data Source FUNCTIONS
    //==============================================================
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let username = currentUser?.username else { return UILabel() }
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.layer.opacity = 0.3
        label.text = "- States \(username) has Visited -"
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "label"
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
    // MARK: - AlertController
    //==============================================================
    func usernameTakenAlert() {
        let alertController = UIAlertController(title: "That username is already taken", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func invalidWarningPercentAlert() {
        let alertController = UIAlertController(title: "Invalid Input", message: "Enter a valid input! Example: 20%", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func warningPercentInfoAlert() {
        if warningPercentInfo == false {
            let alert = UIAlertController(title: "This is your profile", message: "Enter a percent in the Warning Percent text field and you will be warned whenever you enter an area that has a crime percent higher than what you set here.", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Got it!", style: .cancel, handler: { (_) in
                UserDefaults.standard.set(true, forKey: "warningPercentInfo")
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}













