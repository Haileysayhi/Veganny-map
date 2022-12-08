//
//  CommentViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.addRefreshHeader(refreshingBlock: { [weak self] in
                self?.getCommentData()
            })
        }
    }
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Properties
    let dataBase = Firestore.firestore()
    var postId = "" // 接postVC傳過來的資料
    var comments = [Comment]()
    var user: User?
    let group = DispatchGroup()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBase.collection("Post").document(postId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let post = try? snapshot.data(as: Post.self) else { return }
            self.comments = post.comments
            self.tableView.reloadData()
        }
        tableView.beginHeaderRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Comments"
        getCommentData()
    }
    
    // MARK: - Function
    @IBAction func sendComment(_ sender: Any) {
        addData()
    }
    
    func addData() {
        let document = dataBase.collection("Post").document(postId)
        // 使用updateData因此資料不可以是自定義型別需改成dictionary
        let comment: [String: Any] = [
            "content": textField.text ?? "",
            "contentType": ContentType.text.rawValue,
            "userId": getUserID(),
            "time": Timestamp(date: Date())
        ]
        
        document.updateData([
            "comments": FieldValue.arrayUnion([comment])
        ])
        textField.text = ""
    }
    
    func getCommentData() {
        dataBase.collection("Post").document(postId).getDocument(as: Post.self) { result in
            switch result {
            case .success(let post):
                print(post)
                self.comments = post.comments
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.tableView.endHeaderRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    
    func deleteCommentData(indexPath: Int) {
        let document = dataBase.collection("Post").document(postId)
        let comment: [String: Any] = [
            "content": comments[indexPath].content,
            "contentType": comments[indexPath].contentType,
            "userId": comments[indexPath].userId,
            "time": comments[indexPath].time
        ]
        document.updateData([
            "comments": FieldValue.arrayRemove([comment]) // 刪掉留言
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else { fatalError("Could not creat Cell.") }
  
        dataBase.collection("User").document(self.comments[indexPath.row].userId).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                print(user)
                cell.layoutCell(
                    imgView: user.userPhotoURL,
                    name: user.name,
                    content: self.comments[indexPath.row].content,
                    timeStamp: self.comments[indexPath.row].time
                )
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let commentUserID = comments[indexPath.row].userId
        
        if Auth.auth().currentUser?.uid == commentUserID {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, complete) in
                self.deleteCommentData(indexPath: indexPath.row)
                self.comments.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .top)
                complete(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            let trailingSwipConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
            return trailingSwipConfiguration
        } else {
            return nil
        }
    }
}
