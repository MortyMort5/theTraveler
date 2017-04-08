//
//  SearchViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 4/6/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewOnButtonAndLabel()
        self.searchPlaceSeachBar.delegate = self
        var screenEdgeRecognizer: UISwipeGestureRecognizer
        screenEdgeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(transitToMainView))
        screenEdgeRecognizer.direction = .up
        view.addGestureRecognizer(screenEdgeRecognizer)
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var crimeRates: [CrimeRate] = [] {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dangerLevelLabel: UILabel!
    @IBOutlet weak var searchPlaceSeachBar: UISearchBar!
    
    //==============================================================
    // MARK: - Helper Functions
    //==============================================================
    func transitToMainView() {
        let pageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController")
        let transition = CATransition()
        transition.duration = 0.2
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(pageView, animated: true, completion: nil)
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
        
        let textFieldInsideSearchBar = searchPlaceSeachBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor(white: 1.0, alpha: 0.9)
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor(white: 1.0, alpha: 0.3)
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor(white: 1.0, alpha: 0.3)
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor(white: 1.0, alpha: 0.3)
    }
    
    func updateViews() {
        let warningPercent = CrimeRateController.shared.searchedWarningPercent(crimeRates: crimeRates)
        if warningPercent != 0 {
            self.dangerLevelLabel.text = "\(warningPercent)%"
        } else {
            self.dangerLevelLabel.text = "\(1)%"
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchPlaceSeachBar.resignFirstResponder()
        guard let searchPlace = searchPlaceSeachBar.text, !searchPlace.isEmpty else { return }
        self.locationLabel.text = searchPlace
        CrimeRateController.shared.searchedCrimeData(byCurrentLocation: searchPlace) { (crimeRates) in
            if crimeRates.count == 0 {
                DispatchQueue.main.async {
                    self.invalidSearchAlert()
                }
            }
            self.crimeRates = crimeRates
        }
    }
    
    //==============================================================
    // MARK: - Alert Functions
    //==============================================================
    func invalidSearchAlert() {
        guard let searchPlace = searchPlaceSeachBar.text, !searchPlace.isEmpty else { return }
        let alertController = UIAlertController(title: "Nothing was fetched by \(searchPlace))", message: "Make sure to have a coma between the city and state. Example: (Salt Lake City, Utah) If you still don't get results we just don't have that city in our database, sorry.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
