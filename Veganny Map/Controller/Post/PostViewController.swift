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
    let dataBase = Firestore.firestore()
    var didTapButton = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barAppearance = UINavigationBarAppearance()
        // 不要有底線
        barAppearance.shadowColor = nil
        barAppearance.backgroundColor = UIColor.systemOrange
        navigationItem.standardAppearance = barAppearance
        navigationItem.backButtonTitle = ""
        
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
    
    @objc func goToCommentPage(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) // 找出button的座標
        guard let indexpath = tableView.indexPathForRow(at: point) else { return } // 座標轉換成 indexpath
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController {
            controller.postId = posts[indexpath.row].postId
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func tapLike(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) // 找出button的座標
        guard let indexpath = tableView.indexPathForRow(at: point) else { return } // 座標轉換成 indexpath
        let document = dataBase.collection("Post").document(posts[indexpath.row].postId)
        
        if didTapButton {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            sender.tintColor = .black
            
            document.updateData([
                "likes": FieldValue.arrayRemove(["fds9KGgchZFsAIvbauMF"])
            ])
        } else {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .red
            
            document.updateData([
                "likes": FieldValue.arrayUnion(["fds9KGgchZFsAIvbauMF"])
            ])
        }
        didTapButton.toggle()
    }
    
    func getPostData() {
        dataBase.collection("Post").order(by: "time", descending: true).getDocuments { (querySnapshot, error) in
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
        dataBase.collection("User").document(userId).getDocument(as: User.self) { result in
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
        
        if posts[indexPath.row].likes.contains("fds9KGgchZFsAIvbauMF") {
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.likeButton.tintColor = .red
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.likeButton.tintColor = .black
        }
        
        cell.likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
        cell.numberOfCommentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
        cell.postImgView.loadImage(posts[indexPath.row].mediaURL, placeHolder: UIImage(named: "placeholder"))
        cell.contentLabel.text = posts[indexPath.row].content
        getUserData(userId: posts[indexPath.row].authorId)
        cell.userNameLabel.text = user?.name
        cell.userImgView.loadImage(user?.userPhotoURL, placeHolder: UIImage(named: "placeholder"))
        cell.numberOfCommentButton.setTitle("\(posts[indexPath.row].comments.count)則留言", for: .normal)
        
        let timeStamp = posts[indexPath.row].time
        let timeInterval = TimeInterval(Double(timeStamp.seconds))
        cell.timeLabel.text = timeInterval.getReadableDate()
        
        dataBase.collection("Post").document(posts[indexPath.row].postId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let post = try? snapshot.data(as: Post.self) else { return }
            
            if post.likes.isEmpty {
                cell.numberOfLikeLabel.isHidden = true
            } else {
                cell.numberOfLikeLabel.isHidden = false
                cell.numberOfLikeLabel.text = "\(post.likes.count) likes"
            }
        }
        return cell
    }
}