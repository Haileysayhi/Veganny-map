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
            tableView.addRefreshHeader(refreshingBlock: { [weak self] in
                self?.getPostData()
            })
        }
    }
    @IBOutlet weak var changePage: UISegmentedControl! {
        didSet {
            changePage.selectedSegmentTintColor = .systemOrange
            changePage.backgroundColor = .white
            changePage.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemGray2], for: .normal)
            changePage.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        }
    }
    
    // MARK: - Properties
    var posts = [Post]()
    var myPosts = [Post]() // 存登入者自己的發文
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
        navigationController?.navigationBar.tintColor = .systemOrange
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PostTableViewCell")
        tableView.beginHeaderRefreshing() // 出現轉圈圈圖案
        
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
        self.navigationController?.isNavigationBarHidden = true
        getPostData()
        getUserData(userId: getUserID())
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
            if changePage.selectedSegmentIndex == 0 {
                controller.postId = posts[indexpath.row].postId
            } else {
                controller.postId = myPosts[indexpath.row].postId
            }
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
                "likes": FieldValue.arrayRemove([getUserID()])
            ])
        } else {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .systemOrange
            
            document.updateData([
                "likes": FieldValue.arrayUnion([getUserID()])
            ])
        }
        didTapButton.toggle()
    }
    
    func getPostData() {
        dataBase.collection("Post").order(by: "time", descending: true).getDocuments { (querySnapshot, error) in
            self.posts = [] // 清空資料，從其他頁面跳回來時不會重複取資料
            self.myPosts = []
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    do {
                        let post = try document.data(as: Post.self)
                        if post.authorId == getUserID() { // 如果post中的authorId是等於現在登入的使用者ID
                            self.myPosts.append(post)
                        }
                        guard let user = self.user else { return }
                        if !user.blockId.contains(post.authorId) {
                            self.posts.append(post)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.endHeaderRefreshing()
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
    
    @IBAction func changePost(_ sender: UISegmentedControl) {
        tableView.reloadData() // 點選時重新load資料
    }
    
    @objc func goToDetailVC(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) // 找出button的座標
        guard let indexpath = tableView.indexPathForRow(at: point) else { return } // 座標轉換成 indexpath
        
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        else { fatalError("ERROR") }
        
        if changePage.selectedSegmentIndex == 0 {
            GoogleMapListController.shared.fetchPlaceDetail(placeId: posts[indexpath.row].placeId) { detailResponse in
                
                guard let detailResponse = detailResponse else { fatalError("ERROR") }
                tableVC.infoResult = detailResponse.result
                self.present(tableVC, animated: true)
            }
        } else {
            GoogleMapListController.shared.fetchPlaceDetail(placeId: myPosts[indexpath.row].placeId) { detailResponse in
                
                guard let detailResponse = detailResponse else { fatalError("ERROR") }
                tableVC.infoResult = detailResponse.result
                self.present(tableVC, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if changePage.selectedSegmentIndex == 0 {
            return posts.count
        } else {
            return myPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostTableViewCell",
            for: indexPath) as? PostTableViewCell else { fatalError("Could not creat Cell.") }
        cell.delegate = self // 註delegate
        if changePage.selectedSegmentIndex == 0 {
                        
            cell.setupPullDownButton(userID: posts[indexPath.row].authorId )
            
            if posts[indexPath.row].likes.contains(getUserID()) {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = .systemOrange
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.likeButton.tintColor = .black
            }
            cell.likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
            
            cell.stackView.subviews.forEach { subView in
                subView.removeFromSuperview()
                cell.pageControl.numberOfPages = 0
            }
            
            posts[indexPath.row].mediaURL.forEach { imageURL in
                let imageView = UIImageView()
                imageView.loadImage(imageURL, placeHolder: UIImage(named: "placeholder"))
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
                cell.stackView.addArrangedSubview(imageView)
                cell.pageControl.numberOfPages += 1
            }
            
            if posts[indexPath.row].mediaURL.count == 1 {
                cell.pageControl.isHidden = true
            } else {
                cell.pageControl.isHidden = false
            }
            
            cell.contentLabel.text = posts[indexPath.row].content
            
            dataBase.collection("User").document(posts[indexPath.row].authorId).getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    print(user)
                    self.user = user
                    cell.userNameLabel.text = user.name
                    cell.userImgView.loadImage(user.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
                case .failure(let error):
                    print(error)
                }
            }
            
            if posts[indexPath.row].comments.isEmpty {
                cell.numberOfCommentButton.isHidden = true
            } else {
                cell.numberOfCommentButton.isHidden = false
                cell.numberOfCommentButton.text = "\(posts[indexPath.row].comments.count)"
            }
            
            if posts[indexPath.row].location.isEmpty {
                cell.locationButton.isHidden = true
            } else {
                cell.locationButton.isHidden = false
                cell.locationButton.setTitle("\(posts[indexPath.row].location)", for: .normal)
                cell.locationButton.addTarget(self, action: #selector(goToDetailVC), for: .touchUpInside)
            }
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
                    cell.numberOfLikeLabel.text = "\(post.likes.count)"
                }
            }
        } else {
            
            cell.setupPullDownButton(userID: getUserID())
            
            if myPosts[indexPath.row].likes.contains(getUserID()) {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = .systemOrange
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.likeButton.tintColor = .black
            }
            cell.likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
            
            cell.stackView.subviews.forEach { subView in
                subView.removeFromSuperview()
                cell.pageControl.numberOfPages = 0
            }
            
            myPosts[indexPath.row].mediaURL.forEach { imageURL in
                let imageView = UIImageView()
                imageView.loadImage(imageURL, placeHolder: UIImage(named: "placeholder"))
                imageView.contentMode = .scaleAspectFill
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
                cell.stackView.addArrangedSubview(imageView)
                cell.pageControl.numberOfPages += 1
            }
            
            if myPosts[indexPath.row].mediaURL.count == 1 {
                cell.pageControl.isHidden = true
            } else {
                cell.pageControl.isHidden = false
            }
            
            cell.contentLabel.text = myPosts[indexPath.row].content
            
            dataBase.collection("User").document(myPosts[indexPath.row].authorId).getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    print(user)
                    self.user = user
                    cell.userNameLabel.text = user.name
                    cell.userImgView.loadImage(user.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
                case .failure(let error):
                    print(error)
                }
            }
            
            if posts[indexPath.row].comments.isEmpty {
                cell.numberOfCommentButton.isHidden = true
            } else {
                cell.numberOfCommentButton.isHidden = false
                cell.numberOfCommentButton.text = "\(myPosts[indexPath.row].comments.count)"
            }
                        
            if myPosts[indexPath.row].location.isEmpty {
                cell.locationButton.isHidden = true
            } else {
                cell.locationButton.isHidden = false
                cell.locationButton.setTitle("\(myPosts[indexPath.row].location)", for: .normal)
            }
            
            let timeStamp = myPosts[indexPath.row].time
            let timeInterval = TimeInterval(Double(timeStamp.seconds))
            cell.timeLabel.text = timeInterval.getReadableDate()
            
            dataBase.collection("Post").document(myPosts[indexPath.row].postId).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let post = try? snapshot.data(as: Post.self) else { return }
                
                if post.likes.isEmpty {
                    cell.numberOfLikeLabel.isHidden = true
                } else {
                    cell.numberOfLikeLabel.isHidden = false
                    cell.numberOfLikeLabel.text = "\(post.likes.count)"
                }
            }
        }
        return cell
    }
}

// MARK: - PostTableViewCellDelegate
extension PostViewController: PostTableViewCellDelegate {
    
    func deletePost(_ cell: PostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("ERROR") }
        
        
        let controller = UIAlertController(title: "確定刪除貼文嗎？", message: "你將不會再看到已刪除的貼文", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            if self.changePage.selectedSegmentIndex == 0 {
                self.dataBase.collection("Post").document(self.posts[indexPath.row].postId).delete()
                let deletePostId = self.dataBase.collection("User").document(getUserID())
                deletePostId.updateData([
                    "postIds": FieldValue.arrayRemove([self.posts[indexPath.row].postId])
                ])
                guard let postIndex = self.myPosts.firstIndex(where: { $0.postId == self.posts[indexPath.row].postId }) else { return }
                self.myPosts.remove(at: postIndex)
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                CustomFunc.customAlert(title: "已刪除貼文", message: "", vc: self, actionHandler: nil)
            } else {
                self.dataBase.collection("Post").document(self.myPosts[indexPath.row].postId).delete()
                let deletePostId = self.dataBase.collection("User").document(getUserID())
                deletePostId.updateData([
                    "postIds": FieldValue.arrayRemove([self.myPosts[indexPath.row].postId])
                ])
                guard let postIndex = self.posts.firstIndex(where: { $0.postId == self.myPosts[indexPath.row].postId }) else { return }
                self.posts.remove(at: postIndex)
                self.myPosts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                CustomFunc.customAlert(title: "已刪除貼文", message: "", vc: self, actionHandler: nil)
            }
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    func reportPost(_ cell: PostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("ERROR") }
        
        let controller = UIAlertController(title: "確定檢舉這則貼文嗎？", message: "你的檢舉將會匿名", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            if self.changePage.selectedSegmentIndex == 0 {
                let document = self.dataBase.collection("Report").document()
                
                let report = Report(
                    userId: getUserID(),
                    postId: self.posts[indexPath.row].postId,
                    time: Timestamp(date: Date())
                )
                CustomFunc.customAlert(title: "已檢舉完成", message: "謝謝你的意見", vc: self, actionHandler: nil)
                do {
                    try document.setData(from: report)
                } catch {
                    print("ERROR")
                }
            }
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    func blockPeople(_ cell: PostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("ERROR") }
        
        let controller = UIAlertController(title: "確定封鎖該使用者嗎？", message: "你將不會再看到該使用者的貼文", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            if self.changePage.selectedSegmentIndex == 0 {
                let document = self.dataBase.collection("User").document(getUserID())
                let authorId = self.posts[indexPath.row].authorId
                
                document.updateData([
                    "blockId": FieldValue.arrayUnion([authorId]) // 存入封鎖人的id
                ])
                
                self.getUserData(userId: getUserID())
                self.getPostData()
                CustomFunc.customAlert(title: "已封鎖該使用者", message: "你將不會再看到該使用者的貼文", vc: self, actionHandler: nil)
            }
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}
