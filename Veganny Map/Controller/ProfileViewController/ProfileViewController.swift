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
    var container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editProfile: UIButton!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        createCircle(startAngle: 0, endAngle: 180)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width / 1.2 - 15),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImgView.bottomAnchor, constant: 30),
            nameLabel.bottomAnchor.constraint(equalTo: editProfile.topAnchor, constant: -100)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    
    // MARK: - Function
    private func createSegment(startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.view.frame.midX, y: self.view.frame.minY),
                            radius: view.frame.width / 1.2, startAngle: startAngle.toRadians(),
                            endAngle: endAngle.toRadians(),
                            clockwise: true)
    }

    private func createCircle(startAngle: CGFloat, endAngle: CGFloat) {
        let segmentPath = createSegment(startAngle: startAngle, endAngle: endAngle)
        let segmentLayer = CAShapeLayer()
        segmentLayer.path = segmentPath.cgPath
        segmentLayer.lineWidth = 45
        segmentLayer.strokeColor = UIColor.systemOrange.cgColor
        segmentLayer.fillColor = UIColor.systemOrange.cgColor
        container.layer.addSublayer(segmentLayer)
        self.view.insertSubview(container, belowSubview: profileImgView)
    }
    
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


extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}
