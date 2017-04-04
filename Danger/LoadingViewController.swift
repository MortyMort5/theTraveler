//
//  LoadingViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/27/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.holtForASec), name: UserController.shared.CheckingToSeeIfDoneFetchingUser, object: nil)
    }
    
    func holtForASec() {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(LoadingViewController.doneLoading), userInfo: nil, repeats: false)
    }
    
    func doneLoading() {
        if UserController.shared.loadingDone {
            let pageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController")
            self.present(pageView, animated: true, completion: nil)

        }
    }
    
}

