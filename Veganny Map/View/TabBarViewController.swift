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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController,
              let saveVC = storyboard?.instantiateViewController(withIdentifier: "SaveViewController") as? SaveViewController,
              let socialVC = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController,
              let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        else { fatalError("ERROR") }
        
        if Auth.auth().currentUser == nil {
            if viewController == viewControllers?[1]  {
                viewControllers?.replaceSubrange(1...1, with: [vc])
                vc.tabBarItem = UITabBarItem(title: "Social", image: UIImage(systemName: "person.2"), tag: 1)
            } else if viewController == viewControllers?[3] {
                viewControllers?.replaceSubrange(3...3, with: [vc])
                vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
            } else if viewController == viewControllers?[2] {
                viewControllers?.replaceSubrange(2...2, with: [vc])
                vc.tabBarItem = UITabBarItem(title: "Save", image: UIImage(systemName: "heart"), tag: 2)
            }
        } else {
            if viewController == viewControllers?[1]  {
                let navSocialVC = UINavigationController(rootViewController: socialVC)
                navSocialVC.tabBarItem = UITabBarItem(title: "Social", image: UIImage(systemName: "person.2"), tag: 1)
                viewControllers?.replaceSubrange(1...1, with: [navSocialVC])
            } else if viewController == viewControllers?[3] {
                let navProfileVC = UINavigationController(rootViewController: profileVC)
                viewControllers?.replaceSubrange(3...3, with: [navProfileVC])
                navProfileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
                navProfileVC.navigationItem.backButtonTitle = ""

            } else if viewController == viewControllers?[2] {
                let navSaveVC = UINavigationController(rootViewController: saveVC)
                viewControllers?.replaceSubrange(2...2, with: [navSaveVC])
                navSaveVC.tabBarItem = UITabBarItem(title: "Save", image: UIImage(systemName: "heart"), tag: 2)
            }
        }
        self.viewControllers = viewControllers
    }
}
