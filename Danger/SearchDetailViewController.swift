//
//  SearchDetailViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 4/7/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class SearchDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchedTableView.delegate = self
        self.searchedTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let location = CrimeRateController.shared.searchedLocation else { return }
        searchedCityAndStateLabel.text = "for \(location)"
        self.searchedTableView.reloadData()
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var searchedTableView: UITableView!
    @IBOutlet weak var searchedCityAndStateLabel: UILabel!
    
    //==============================================================
    // MARK: - Data Source
    //==============================================================
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "- Crime Type & Crime Count -"
        label.backgroundColor = UIColor.clear
        label.layer.opacity = 0.7
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "label"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CrimeRateController.shared.searchedCrimeRate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crimeCell", for: indexPath)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
        } else {
            cell.backgroundColor = UIColor.clear
        }
        let crimeRate = CrimeRateController.shared.searchedCrimeRate[indexPath.row]
        cell.textLabel?.text = crimeRate.type
        cell.detailTextLabel?.text = crimeRate.count
    
        return cell
    }
}
