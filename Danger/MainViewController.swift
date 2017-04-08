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
import UserNotifications

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewOnButtonAndLabel()
        currentUser = UserController.shared.loggedInUser
        findLocation()
        
        var screenEdgeRecognizer: UISwipeGestureRecognizer
        screenEdgeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(transitToSearchView))
        screenEdgeRecognizer.direction = .down
        view.addGestureRecognizer(screenEdgeRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserController.shared.loggedInUser
        if currentUser != nil {
            travelersInfoAlert()
        }
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    static var shared = MainViewController()
    var locationManager: CLLocationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var currentUser: User?
    var locationCount = 0
    let hour: TimeInterval = 3600
    var curLocationCityAndState: String?
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
    @IBOutlet weak var travelChartButton: UIButton!
    
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
    func transitToSearchView() {
        let searchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchPageViewController")
        let transition = CATransition()
        transition.duration = 0.1
        transition.subtype = kCATransitionFromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(searchView, animated: false, completion: nil)
    }
    
    func updateViewOnButtonAndLabel() {
        let circleView = UIView()
        circleView.center = self.view.center
        circleView.bounds = CGRect(x: 0.0, y: 0.0, width: 250.0, height: 250.0)
        circleView.layer.cornerRadius = 250.0 / 2
        circleView.layer.borderWidth = 1
        circleView.layer.opacity = 0.3
        circleView.layer.backgroundColor = UIColor.clear.cgColor
        circleView.layer.borderColor = UIColor.white.cgColor
        view.addSubview(circleView)
        
        let borderAlpha : CGFloat = 0.3
        self.travelChartButton.layer.cornerRadius = 5
        self.travelChartButton.layer.borderWidth = 1
        self.travelChartButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
    }
    
    func findLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
    }
    
    func regionMonitoring(lat: Double, long: Double) {
        let currentRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(lat, long), radius: 10000, identifier: "userLocation")
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
        CrimeRateController.shared.fetchCrimeData(byCurrentLocation: "\(city), \(state)") { (crimeRate) in
            if crimeRate.count == 0 {
                print("Nothing was fetched from the API")
            }
            DispatchQueue.main.async {
                let percent = CrimeRateController.shared.warningPercent
                if percent != 0 {
                    self.percentLabel.text = "\(percent)%"
                } else {
                    self.percentLabel.text = "\(1)%"
                }
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
            self.locationManager.requestLocation()
            self.requestNotificationAuthorization()
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
            let alert = UIAlertController(title: "You have Access to:", message: "The Travel Chart button below. User that travels to the most states in a month get's a prize", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Got it!", style: .cancel, handler: { (_) in
                UserDefaults.standard.set(true, forKey: "TravelersInfoAlertProperty")
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            if let error = error {
                print("Notification authorization failed, or was denied \(error.localizedDescription)")
            } else {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}














