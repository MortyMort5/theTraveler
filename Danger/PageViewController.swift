//
//  PageViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.setCurrentUser), name: UserController.shared.UserIsLoggedIn, object: nil)
        dataSource = self
        self.delegate = self
        verifyUser()
//        configurePageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserController.shared.loggedInUser
        if currentUser != nil {
            verifyUser()
            self.dataSource = nil
            self.dataSource = self
            self.delegate = self
//            self.configurePageControl()
        }
    }
    
    func setCurrentUser() {
        self.dataSource = nil
        self.dataSource = self
        self.delegate = self
        currentUser = UserController.shared.loggedInUser
        if currentUser != nil {
            verifyUser()
//            self.configurePageControl()
        }
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var pageControl = UIPageControl()
    var currentUser: User?
    private(set) lazy var orderedViewControllers: [UIViewController] = []
    
    //==============================================================
    // MARK: - The array of viewControllers
    //==============================================================
    private func newViewController(view: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(view)ViewController")
    }
    
    //==============================================================
    // MARK: - Verifying User and displaying Setting View Controller
    //==============================================================
    func verifyUser() {
        orderedViewControllers = {
            if self.currentUser != nil {
                return [self.newViewController(view: "UserSetting"), self.newViewController(view: "Main"), self.newViewController(view: "Detail")]
            } else {
                return [self.newViewController(view: "Main"), self.newViewController(view: "Detail")]
            }
        }()
        
        if orderedViewControllers.count == 2 {
            setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
        } else if orderedViewControllers.count == 3 {
            setViewControllers([orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    //==============================================================
    // MARK: - This sets up the dots at the bottom
    //==============================================================
//    func configurePageControl() {
//        if currentUser != nil {
//            if let viewWithTag = pageControl.viewWithTag(100) {
//                viewWithTag.removeFromSuperview()
//            }
//            pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
//            self.pageControl.numberOfPages = orderedViewControllers.count
//            self.pageControl.currentPage = 1
//            self.pageControl.tintColor = UIColor.black
//            self.pageControl.pageIndicatorTintColor = UIColor.white
//            self.pageControl.currentPageIndicatorTintColor = UIColor(red: 238.0/255, green: 133.0/255, blue: 113.0/255, alpha: 1.0)
//            self.view.addSubview(pageControl)
//        } else {
//            pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
//            self.pageControl.numberOfPages = orderedViewControllers.count
//            self.pageControl.currentPage = 0
//            self.pageControl.tintColor = UIColor.black
//            self.pageControl.pageIndicatorTintColor = UIColor.white
//            self.pageControl.currentPageIndicatorTintColor = UIColor(red: 238.0/255, green: 133.0/255, blue: 113.0/255, alpha: 1.0)
//            self.pageControl.tag = 100
//            self.view.addSubview(pageControl)
//        }
//    }
    
    //==============================================================
    // MARK: - Indicates changes to the correct page as you scroll
    //==============================================================
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    //==============================================================
    // MARK: - Keeping track of the index of the page you're on
    //==============================================================
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
