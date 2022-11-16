//
//  ProfileViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/11.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
    }
    
    
    // MARK: - Function
    @IBAction func signOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                var viewController = self.tabBarController?.viewControllers
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                else { fatalError("ERROR") }
                vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
                viewController?.replaceSubrange(3...3, with: [vc])
                self.tabBarController?.viewControllers = viewController
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
