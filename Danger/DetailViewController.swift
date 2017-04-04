//
//  DetailViewController.swift
//  ITravels
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserController.shared.loggedInUser
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User?
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var crimeStatsTableView: UITableView!
    
    //==============================================================
    // MARK: - Data Source Functions
    //==============================================================
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.black
        label.backgroundColor = UIColor(red: 250.0/255, green: 232.0/255, blue: 124.0/255, alpha: 1.0)
        label.text = "- Crime Type & Crime Count -"
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "label"
    }
    
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
}




