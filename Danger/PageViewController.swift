//
//  PageViewController.swift
//  Danger
//
//  Created by Sterling Mortensen on 3/13/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        self.delegate = self
        configurePageControl()
        
        if orderedViewControllers.count > 1 {
            setViewControllers([orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentUser = UserController.shared.loggedInUser
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var pageControl = UIPageControl()
    var currentUser: User?
    
    //==============================================================
    // MARK: - The array of viewControllers
    //==============================================================
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(view: "UserSetting"), self.newViewController(view: "Main"), self.newViewController(view: "Detail")]
    }()
    
    private func newViewController(view: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(view)ViewController")
    }
    
    //==============================================================
    // MARK: - This sets up the dots at the bottom
    //==============================================================
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 1
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 238.0/255, green: 133.0/255, blue: 113, alpha: 1.0)
        self.view.addSubview(pageControl)
    }
    
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
