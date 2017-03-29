//
//  AlertController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/24/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class AlertController {
    static let shared = AlertController()
    func userNameTakinAlert() {
        let alertController = UIAlertController(title: "That username is already taken", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
    }
}
