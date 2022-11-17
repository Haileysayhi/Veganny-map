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
    var didTapButton = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - function
    @objc func saveRestaurantId(_ sender: UIButton) {
        let document = dataBase.collection("User").document(getUserID())
        let placeId = infoResult?.placeId as! String
        
        if didTapButton {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            sender.tintColor = .systemOrange
            
            document.updateData([
                "savedRestaurants": FieldValue.arrayRemove([placeId]) // 刪掉餐廳的id
            ])
            
            let alertView = SPAlertView(title: "Remove from save", preset: .done)
            alertView.duration = 0.5
            alertView.present()
            
        } else {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .red
            
            document.updateData([
                "savedRestaurants": FieldValue.arrayUnion([placeId]) // 存入餐廳的id
            ])
            
            let alertView = SPAlertView(title: "Add to save", preset: .heart)
            alertView.duration = 0.5
            alertView.present()
        }
        didTapButton.toggle()
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
            headerView.textLabel?.font = UIFont(name: "PingFangTC-Medium", size: 18)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
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
            
            dataBase.collection("User").document(getUserID()).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                if user.savedRestaurants.contains(self.infoResult!.placeId) {
                    cell.saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    cell.saveButton.tintColor = .red
                } else {
                    cell.saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    cell.saveButton.tintColor = .systemOrange
                }
            }
            
            cell.saveButton.addTarget(self, action: #selector(saveRestaurantId), for: .touchUpInside)
            cell.nameLabel.text = infoResult.name
            cell.addressLabel.text = infoResult.formattedAddress
            cell.workHourLabel.text = infoResult.currentOpeningHours.weekdayText.map({$0}).joined(separator: "\n")
        
            cell.phoneLabel.text = infoResult.internationalPhoneNumber
            cell.reviewsLabel.text = "\(infoResult.rating)"
            return cell
            
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ReviewTableViewCell",
                for: indexPath) as? ReviewTableViewCell else { fatalError("Could not create Cell") }
            
            cell.reviews = infoResult.reviews // 傳資料給 ReviewTableViewCell
            print("真正的傳資料給 ReviewTableViewCell\(infoResult.reviews)")
            return cell
            
        } else { fatalError("ERROR") }
    }
}
