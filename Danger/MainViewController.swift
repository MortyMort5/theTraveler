//
//  MainViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/8/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = UserController.shared.loggedInUser
        switchBackgroundImageForUser()
        findLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserController.shared.loggedInUser
        switchBackgroundImageForUser()
        if currentUser != nil {
            travelersInfoAlert()
        }
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var locationManager: CLLocationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var currentUser: User?
    var locationCount = 0
    let hour: TimeInterval = 3600
    static let shared = MainViewController()
    weak var mapView: MKMapView?
    var TravelersInfoAlertProperty:Bool {
        return UserDefaults.standard.bool(forKey: "TravelersInfoAlertProperty")
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func travelLogButtonTapped(_ sender: Any) {
        if (currentUser != nil) {
            let travelLogController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TravelLogViewController")
            self.present(travelLogController, animated: true, completion: nil)
        } else {
            let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginController, animated: true, completion: nil)
        }
    }
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
    func findLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestLocation()
    }
    
    func switchBackgroundImageForUser() {
        if currentUser != nil {
            let background = UIImageView(image: #imageLiteral(resourceName: "User"))
            self.backgroundImage.image = background.image
        }
    }
    
    func regionMonitoring(lat: Double, long: Double) {
        let currentRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(lat, long), radius: 5000, identifier: "userLocation")
        locationManager.startMonitoring(for: currentRegion)
        print("Made Region")
    }
    
    func fetchCityAndStateFor(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("reverse geolocation failed with an error: \(error.localizedDescription)")
            }
            guard let placemarksArr = placemarks else { return }
            if placemarksArr.count > 0 && placemarksArr.count < 5 && self.isViewLoaded {
                let pm = placemarksArr[0] as CLPlacemark
                guard let city = pm.locality, let state = pm.administrativeArea else { return }
                self.cityLabel.text = "\(city), \(state)"
                guard let fullNameState = States.states[state] else { return }
                self.checkAndAddState(state: fullNameState)
                self.fetchCrimeData(city: city, state: fullNameState)
            } else {
                print("Problem with the data received from gocoder")
            }
        }
    }

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
    
    func fetchCrimeData(city: String, state: String) {
        CrimeRateController.shared.fetchCrimeData(byCurrentLocation: "\(city), \(state)") { (error) in
            if error != nil {
                print("Error with fetching Crime Data")
            }
            DispatchQueue.main.async {
                self.percentLabel.text = "\(CrimeRateController.shared.warningPercent)%"
            }
        }
    }
    
    //==============================================================
    // MARK: - Location Manager Functions
    //==============================================================
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCount += 1
        print(locationCount)
        guard let location = manager.location else { return }
        if locationCount == 1 {
            regionMonitoring(lat: location.coordinate.latitude, long: location.coordinate.longitude)
            self.fetchCityAndStateFor(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let location = manager.location else { return }
        print("Exited Region")
        regionMonitoring(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        fetchCityAndStateFor(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Not Determined
        if status.hashValue == 0 {
            print("Not yet Determined Access")
        }
        
        // Restricted
        if status.hashValue == 1 {
            self.restrictedAccessAlert()
        }
        
        // Denied
        if status.hashValue == 2 {
            self.deniedAccessAlert()
        }
        
        // Always allow
        if status.hashValue == 3 {
            print("Always allowed access")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while fetching current location \(error.localizedDescription)")
    }
    
    //==============================================================
    // MARK: - Alert Functions
    //==============================================================
    func deniedAccessAlert() {
        let alertController = UIAlertController(title: "Denied Access to your Location", message: "We need access to your location inorder for you to use this app:", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let allowAction = UIAlertAction(title: "Allow", style: .default) { (_) in
            self.locationManager.requestAlwaysAuthorization()
        }
        alertController.addAction(noAction)
        alertController.addAction(allowAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func restrictedAccessAlert() {
        let alertController = UIAlertController(title: "Restricted Access to your location", message: "Possibly due to active restrictions such as parental controls being in place.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func travelersInfoAlert() {
        if TravelersInfoAlertProperty == false {
            let alert = UIAlertController(title: "The TRAVELERS button!", message: "Will show all the users and the count of how many states they have traveled to this month. The user with the most at the end of the month gets a prize", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Got it!", style: .cancel, handler: { (_) in
                UserDefaults.standard.set(true, forKey: "TravelersInfoAlertProperty")
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func alwaysTrackCurrLocatinAlert() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
















