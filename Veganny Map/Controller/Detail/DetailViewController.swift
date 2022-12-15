//
//  DetailViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import SPAlert

class DetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Properties
    var infoResult: InfoResult?
    let dataBase = Firestore.firestore()
    
    let firestoreService = FirestoreService.shared
    
    var didTapButton = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    // MARK: - function
    @objc func saveRestaurantId(_ sender: UIButton) {
        
        let docRef = VMEndpoint.user.ref.document(getUserID())
        let placeId = infoResult?.placeId as! String

        if didTapButton {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            sender.tintColor = .systemOrange
            
            firestoreService.arrayRemove(docRef, field: "savedRestaurants", value: placeId)
            
            let alertView = SPAlertView(title: "Remove from save", preset: .done)
            alertView.duration = 0.5
            alertView.present()
        } else {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .systemPink
            
            firestoreService.arrayUnion(docRef, field: "savedRestaurants", value: placeId)
            
            let alertView = SPAlertView(title: "Add to save", preset: .heart)
            alertView.duration = 0.5
            alertView.present()
        }
        didTapButton.toggle()
    }
    
    
    @objc func showSignInVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signInVC = storyboard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self))
                as? SignInViewController
        else { fatalError("Could not instantiate SignInViewController") }
        present(signInVC, animated: true)
    }
    
    @IBAction func callRestaurant(_ sender: Any) {
        let phoneNumber = infoResult!.internationalPhoneNumber as! String
        let newStringPhone = phoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        if let url = URL(string: "tel:\(newStringPhone)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("無法開啟URL")
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // 如果第0個section 回傳兩個cell
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Reviews"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .black
            headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let infoResult = infoResult else { fatalError("Could not fetch data.") }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "PhotoTableViewCell",
                for: indexPath) as? PhotoTableViewCell else { fatalError("Could not create Cell") }
            
            cell.photos = infoResult.photos // 傳資料給 PhotoTableViewCell
            return cell
            
        } else if indexPath.section == 0 && indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "InfoTableViewCell",
                for: indexPath) as? InfoTableViewCell else { fatalError("Could not create Cell") }
            
            if getUserID().isEmpty {
                cell.saveButton.addTarget(self, action: #selector(showSignInVC), for: .touchUpInside)
            } else {
                dataBase.collection("User").document(getUserID()).addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    guard let user = try? snapshot.data(as: User.self) else { return }
                    
                    cell.setupButton(savedRestaurants: user.savedRestaurants, placeId: self.infoResult!.placeId)
                }
                cell.saveButton.addTarget(self, action: #selector(saveRestaurantId), for: .touchUpInside)
            }
            
            cell.layoutCell(
                name: infoResult.name,
                address: infoResult.formattedAddress,
                workHour: infoResult.currentOpeningHours.weekdayText.map({$0}).joined(separator: "\n"),
                phone: infoResult.internationalPhoneNumber,
                reviews: "\(infoResult.rating)"
            )
            return cell
            
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ReviewTableViewCell",
                for: indexPath) as? ReviewTableViewCell else { fatalError("Could not create Cell") }
            cell.viewController = self
            cell.reviews = infoResult.reviews // 傳資料給 ReviewTableViewCell
            return cell
            
        } else { fatalError("ERROR") }
    }
}
