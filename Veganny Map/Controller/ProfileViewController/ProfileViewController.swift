//
//  ProfileViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/11.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    
    // MARK: - Properties
    let dataBase = Firestore.firestore()
    var user: User?
//    let orangeView = SemiCirleView.self
    var orangeView: SemiCirleView!
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if self.orangeView != nil {
//            orangeView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(orangeView)
//            orangeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            orangeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        } else {
//            return
//        }
//    }
    
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
    
    @IBAction func showEditProfilePage(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        dataBase.collection("User").document(userId).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                print(user)
                self.user = user
                self.profileImgView.loadImage(self.user?.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
                self.nameLabel.text = self.user?.name
            case .failure(let error):
                print(error)
            }
        }
    }
}
