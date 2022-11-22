//
//  TabBarViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/15.
//

import UIKit
import FirebaseAuth

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        UINavigationBar.appearance().tintColor = .systemOrange
    }
    
    // MARK: - Function
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        var viewControllers = self.viewControllers
        
        if Auth.auth().currentUser == nil {
            print("No user is signed in.")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let signInVC = storyboard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self))
                    as? SignInViewController
            else { fatalError("Could not instantiate SignInViewController") }
            
            if viewController == viewControllers?[3] {
                signInVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
                viewControllers?.replaceSubrange(3...3, with: [signInVC])
            } else if viewController == viewControllers?[2] {
                signInVC.tabBarItem = UITabBarItem(title: "Save", image: UIImage(systemName: "heart"), tag: 2)
                viewControllers?.replaceSubrange(2...2, with: [signInVC])
            }  else if viewController == viewControllers?[1] {
                signInVC.tabBarItem = UITabBarItem(title: "Social", image: UIImage(systemName: "person.2"), tag: 1)
                viewControllers?.replaceSubrange(1...1, with: [signInVC])
            }
        } else {
            print("User is signed in.")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let tabController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self))
                    as? TabBarViewController,
                let tabBarControllers = tabController.viewControllers
            else { fatalError("Could not instantiate tabController") }
            viewControllers?.replaceSubrange(3...3, with: [tabBarControllers[3]])
            viewControllers?.replaceSubrange(2...2, with: [tabBarControllers[2]])
            viewControllers?.replaceSubrange(1...1, with: [tabBarControllers[1]])
        }
        self.viewControllers = viewControllers
    }
}
