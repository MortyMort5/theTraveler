//
//  SearchPageViewController.swift
//  ITravels
//
//  Created by Sterling Mortensen on 4/7/17.
//  Copyright © 2017 Sterling Mortensen. All rights reserved.
//

import UIKit

class SearchPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        self.delegate = self
        verifyUser()
    }
    
    var pageControl = UIPageControl()
    private(set) var orderedViewControllers: [UIViewController] = []
    
    private func newViewController(view: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(view)ViewController")
    }
    
    func verifyUser() {
        orderedViewControllers = {
            return [self.newViewController(view: "Search"), self.newViewController(view: "SearchDetail")]
        }()
        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
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
