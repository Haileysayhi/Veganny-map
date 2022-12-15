//
//  BlockListViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/24.
//

import UIKit
import FirebaseAuth

class BlockListViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.addRefreshHeader(refreshingBlock: { [weak self] in
                self?.getUserData()
            })
        }
    }
    // MARK: - Properties
    var user: User?
    var blockUser: User?
    let firestoreService = FirestoreService.shared
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    
    // MARK: - Function
    func getUserData() {
        let docRef = VMEndpoint.user.ref.document(getUserID())
        firestoreService.getDocument(docRef) { [weak self] (user: User?) in
            guard let self = self else { return }
            self.user = user
            DispatchQueue.main.async {
                self.tableView.endHeaderRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func removeFromBlockList(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) // 找出button的座標
        guard let indexpath = tableView.indexPathForRow(at: point) else { return } // 座標轉換成 indexpath
        
        let blockUserId = user?.blockId[indexpath.row]
        let docRef = VMEndpoint.user.ref.document(getUserID())
        firestoreService.arrayRemove(docRef, field: "blockId", value: blockUserId)
        
        user?.blockId.remove(at: indexpath.row)
        tableView.deleteRows(at: [indexpath], with: .fade)
        CustomFunc.customAlert(title: "已解除封鎖", message: "你將可以看到該使用者的貼文", vc: self, actionHandler: nil)
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
        
        let docRef = VMEndpoint.user.ref.document(user.blockId[indexPath.row])
        
        firestoreService.getDocument(docRef) { [weak self] (user: User?) in
            guard let self = self else { return }
            guard let user = user else { return }
            
            self.blockUser = user
            cell.layoutCell(
                image: user.userPhotoURL,
                name: user.name
            )
            cell.unblockButton.addTarget(self, action: #selector(self.removeFromBlockList), for: .touchUpInside)
        }
        return cell
    }
}
