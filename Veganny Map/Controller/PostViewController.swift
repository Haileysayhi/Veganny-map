//
//  PostViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class PostViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - Properties
    var posts = [Post]()
    var user: User?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PostTableViewCell")
        
        let floatingButton = UIButton()
        floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingButton.tintColor = .white
        floatingButton.backgroundColor = .orange
        floatingButton.layer.cornerRadius = 25
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 50),
            floatingButton.heightAnchor.constraint(equalToConstant: 50),
            floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10)
        ])
        
        floatingButton.addTarget(self, action: #selector(goToPublishPage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPostData()
    }
    
    // MARK: - Function
    @objc func goToPublishPage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "PublishViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func goToCommentPage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func getPostData() {
        Firestore.firestore().collection("Post").order(by: "time", descending: true).getDocuments { (querySnapshot, error) in
            self.posts = [] // 清空資料，從其他頁面跳回來時不會重複取資料
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    do {
                        let post = try document.data(as: Post.self)
                        self.posts.append(post)
                        print("===firebase:\(post)")
                    } catch {
                        print(error)
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getUserData(userId: String) {
        Firestore.firestore().collection("User").document(userId).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                print(user)
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostTableViewCell",
            for: indexPath) as? PostTableViewCell else { fatalError("Could not creat Cell.") }

        cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
        cell.postImgView.loadImage(posts[indexPath.row].mediaURL, placeHolder: UIImage(named: "placeholder"))
        cell.contentLabel.text = posts[indexPath.row].content
        getUserData(userId: posts[indexPath.row].authorId)
        cell.userNameLabel.text = user?.name
        cell.userImgView.loadImage(user?.userPhotoURL, placeHolder: UIImage(named: "placeholder"))
        cell.numberOfCommentButton.setTitle("\(posts[indexPath.row].comments.count)則留言", for: .normal)
        
        return cell
    }
}
