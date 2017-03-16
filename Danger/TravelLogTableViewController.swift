//
//  TravelLogTableViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class TravelLogTableViewController: UITableViewController {
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelLogCell", for: indexPath)
        
        return cell
    }
}
