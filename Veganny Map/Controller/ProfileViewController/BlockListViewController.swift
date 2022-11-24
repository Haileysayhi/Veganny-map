//
//  BlockListViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class BlockListViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.addRefreshHeader(refreshingBlock: { [weak self] in
                self?.getUserData(userId: getUserID())
            })
        }
    }
    // MARK: - Properties
    var user: User?
    var blockUser: User?
    let dataBase = Firestore.firestore()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData(userId: getUserID())
    }
    // MARK: - Function
    func getUserData(userId: String) {
        dataBase.collection("User").document(userId).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.user = user
                print("===BlockListViewController\(user)")
                DispatchQueue.main.async {
                    self.tableView.endHeaderRefreshing()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BlockListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.blockId.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListTableViewCell", for: indexPath) as? BlockListTableViewCell
        else { fatalError("Could not create Cell.") }
        guard let user = self.user else { fatalError("ERROR") }
        
        dataBase.collection("User").document(user.blockId[indexPath.row]).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.blockUser = user
                cell.nameLabel.text = user.name
                cell.profileImgView.loadImage(user.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }
}
