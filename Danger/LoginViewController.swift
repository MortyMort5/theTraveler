//
//  LoginViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/14/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewOnButtons()
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.usernameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.loadingIndicator.startAnimating()
        guard let username = usernameTextField.text, !username.isEmpty else { self.loadingIndicator.stopAnimating(); self.blankTextFieldAlert(); return }
        guard let email = emailTextField.text, !email.isEmpty else { self.loadingIndicator.stopAnimating(); self.emailBlankAlert(); return }
        UserController.shared.saveUserData(username: username, email: email) { (bool) in
            DispatchQueue.main.async {
                if bool {
                    print("dublicate name")
                    self.loadingIndicator.stopAnimating()
                    self.usernameTakenAlert()
    
                } else {
                    UserDefaults.standard.set(true, forKey: "userHasCreatedAnAccount")
                    self.loadingIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    //==============================================================
    // MARK: - UIText Field Functions
    //==============================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
    func updateViewOnButtons() {
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    //==============================================================
    // MARK: - Alert Functions
    //==============================================================
    func usernameTakenAlert() {
        let alertController = UIAlertController(title: "That username is already taken", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func emailBlankAlert() {
        let alertController = UIAlertController(title: "Invalid Email:", message: "The only time we will use your email is if you win the Traveler's Competition. Make sure it's correct and valid.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func blankTextFieldAlert() {
        let alertController = UIAlertController(title: "Fill in all the text fields", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}
