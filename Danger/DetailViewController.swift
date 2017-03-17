//
//  DetailViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        crimeStatsTableView.delegate = self
        crimeStatsTableView.dataSource = self
        verifyUserButton.setTitle("", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
        currentUser = UserController.shared.loggedInUser
        verifyUser()
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User?
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func saveButtonTapped(_ sender: Any) {
        if currentUser != nil {
            guard let warningPercent = alertPercentTextField.text, !warningPercent.isEmpty, let percent = Int(warningPercent) else { return }
            UserController.shared.addToUserRecord(warningPercent: percent, completion: { 
              print("Saved to cloudkit with: \(percent)")
                
                
            })
        }
    }
    
    @IBAction func verifyUserButtonTapped(_ sender: Any) {
        let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginController, animated: true, completion: nil)
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var verifyUserButton: UIButton!
    @IBOutlet weak var crimeStatsTableView: UITableView!
    @IBOutlet weak var alertPercentTextField: UITextField!
    
    //==============================================================
    // MARK: - Data Source Functions
    //==============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CrimeRateController.shared.crimeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crimeDetailCell", for: indexPath)
        
        let crimeRate = CrimeRateController.shared.crimeRates[indexPath.row]
        
        cell.textLabel?.text = crimeRate.type
        cell.detailTextLabel?.text = crimeRate.count
        return cell
    }
    
    //==============================================================
    // MARK: - Alert Functions
    //==============================================================
    func alertUserOfDanger() {
        guard let percent = alertPercentTextField.text, !percent.isEmpty else { return }
        let newPercent = percent.replacingOccurrences(of: "%", with: "")
        guard let setPercent = Int(newPercent) else { return }
    }
    
    //==============================================================
    // MARK: - Verify User
    //==============================================================
    func verifyUser() {
        if currentUser != nil {
            self.view.sendSubview(toBack: verifyUserButton)
        }
    }
}




