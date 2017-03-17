//
//  LoginViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        cancelButton.isEnabled = false
        submitButton.isEnabled = false
        guard let username = usernameTextField.text, let email = emailTextField.text, !email.isEmpty, !username.isEmpty else { return }
        UserController.shared.saveUserData(username: username, email: email) {
            self.cancelButton.isEnabled = true
            self.submitButton.isEnabled = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
