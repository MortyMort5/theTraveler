//
//  MainViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/8/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
        currentUser = UserController.shared.loggedInUser
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var locationManager: CLLocationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var currentUser: User?
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func travelLogButtonTapped(_ sender: Any) {
        if (currentUser != nil) {
            let travelLogController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TravelLogTableViewController")
            self.present(travelLogController, animated: true, completion: nil)
        } else {
            let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginController, animated: true, completion: nil)
        }
    }
    
    //==============================================================
    // MARK: - Current Location
    //==============================================================
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else { return }
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("reverse geolocation failed with an error: \(error.localizedDescription)")
            }
            
            guard let placemarksArr = placemarks else { return }
            
            if placemarksArr.count > 0 {
                let pm = placemarksArr[0] as CLPlacemark
                guard let city = pm.locality, let state = pm.administrativeArea else { return }
                self.cityLabel.text = "\(city), \(state)"
                self.locationManager.stopUpdatingLocation()
                guard let fullNameState = States.states[state] else { return }
                self.checkAndAddState(state: fullNameState)
                self.fetchCrimeData(city: city, state: fullNameState)
            } else {
                print("Problem with the data received from gocoder")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while fetching current location \(error.localizedDescription)")
    }
    
    //==============================================================
    // MARK: - Checks if current state is in array and if not appends state
    //==============================================================
    func checkAndAddState(state: String?) {
        guard let state = state else { return }
        if currentUser != nil {
            if !(currentUser?.states.contains(state))! {
                UserController.shared.addStateToRecord(state: state, completion: { 
                    print("Added State to states Array")
                })
            }
        }
    }
    
    //==============================================================
    // MARK: - Fetch CrimeRate for current location with city and state
    //==============================================================
    func fetchCrimeData(city: String, state: String) {
        CrimeRateController.shared.fetchCrimeData(byCurrentLocation: "\(city), \(state)", completion: { (crimeRates) in
            if crimeRates.count == 0 {
                print("Nothing was fetched by that city and state")
            }
            self.percentLabel?.text = "\(crimeRates[0].warningPercent)%"
            if (self.currentUser != nil)  {
                guard let user = self.currentUser else { return }
                if user.warningPercent! >= crimeRates[0].warningPercent {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLoad), name: CrimeRateController.shared.crimeIsAboveSetPercent, object: nil)
                    print("Hit notification Observer")
                }
            }
        })
    }
}
















