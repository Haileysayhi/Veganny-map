//
//  PostViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import MaterialComponents.MaterialButtons

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
    var currentPage = ChangePage.all
    let firestoreService = FirestoreService.shared
    var didTapButton = false
    let floatingButton = MDCFloatingButton(shape: .default)
    var lastContentOffset: CGFloat = 0
    
    enum ChangePage: Int {
        case all, mine
    }
    
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
        
        setupFloatingButton(button: floatingButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        getPostData()
        getUserData()
    }
    
    // MARK: - Function
    func setupFloatingButton(button: MDCFloatingButton) {
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setImageTintColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10)
        ])
        button.addTarget(self, action: #selector(goToPublishPage), for: .touchUpInside)
    }
    
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
        
        guard let changePages = ChangePage(rawValue: self.changePage.selectedSegmentIndex)
        else { fatalError("ERROR") }
        switch changePages {
        case .all:
            let docRef = VMEndpoint.post.ref.document(posts[indexpath.row].postId)
            if didTapButton {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
                sender.tintColor = .black
                firestoreService.arrayRemove(docRef, field: "likes", value: getUserID())
            } else {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                sender.tintColor = .systemOrange
                firestoreService.arrayUnion(docRef, field: "likes", value: getUserID())
            }
            didTapButton.toggle()
        case .mine:
            let docRef = VMEndpoint.post.ref.document(myPosts[indexpath.row].postId)
            if didTapButton {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
                sender.tintColor = .black
                firestoreService.arrayRemove(docRef, field: "likes", value: getUserID())
            } else {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                sender.tintColor = .systemOrange
                firestoreService.arrayUnion(docRef, field: "likes", value: getUserID())
            }
            didTapButton.toggle()
        }
    }
    
    func getPostData() {
        
        let postQuery = VMEndpoint.post.ref.order(by: "time", descending: true)
        firestoreService.getDocuments(postQuery) { [weak self] (posts: [Post]) in
            guard let self = self else { return }
            self.posts = [] // 清空資料，從其他頁面跳回來時不會重複取資料
            self.myPosts = []
            for post in posts {
                if post.authorId == getUserID() { // 如果post中的authorId是等於現在登入的使用者ID
                    self.myPosts.append(post)
                }
                guard let user = self.user else { return }
                if !user.blockId.contains(post.authorId) {
                    self.posts.append(post)
                }
            }
            DispatchQueue.main.async {
                self.tableView.endHeaderRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func getUserData() {
        
        let docRef = VMEndpoint.user.ref.document(getUserID())
        firestoreService.getDocument(docRef) { [weak self] (user: User?) in
            guard let self = self else { return }
            self.user = user
        }
    }
    
    @IBAction func changePost(_ sender: UISegmentedControl) {
        guard let currentPage = ChangePage(rawValue: sender.selectedSegmentIndex) else { return }
        self.currentPage = currentPage
        tableView.reloadData() // 點選時重新load資料
    }
    
    @objc func goToDetailVC(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) // 找出button的座標
        guard let indexpath = tableView.indexPathForRow(at: point) else { return } // 座標轉換成 indexpath
        
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        else { fatalError("ERROR") }
        
        switch currentPage {
        case .all:
            GoogleMapListController.shared.fetchPlaceDetail(placeId: posts[indexpath.row].placeId) { detailResponse in
                guard let detailResponse = detailResponse else { fatalError("ERROR") }
                tableVC.infoResult = detailResponse.result
                self.present(tableVC, animated: true)
            }
            
        case .mine:
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
        
        switch currentPage {
        case .all:
            return posts.count
        case .mine:
            return myPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostTableViewCell",
            for: indexPath) as? PostTableViewCell else { fatalError("Could not creat Cell.") }
        cell.delegate = self // 註delegate
        
        switch currentPage {
        case .all:
            cell.setupPullDownButton(userID: posts[indexPath.row].authorId )
            cell.setupButton(likes: posts[indexPath.row].likes, userId: getUserID())
            cell.likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
            cell.setupStackView(mediaURL: posts[indexPath.row].mediaURL)
            
            let docRef = VMEndpoint.user.ref.document(posts[indexPath.row].authorId)
            
            firestoreService.getDocument(docRef) { [weak self] (user: User?) in
                guard let self = self else { return }
                self.user = user
                cell.setupPost(
                    name: user!.name,
                    image: user!.userPhotoURL,
                    content: self.posts[indexPath.row].content,
                    comments: self.posts[indexPath.row].comments,
                    timeStamp: self.posts[indexPath.row].time,
                    postId: self.posts[indexPath.row].postId,
                    location: self.posts[indexPath.row].location
                )
            }
            cell.locationButton.addTarget(self, action: #selector(goToDetailVC), for: .touchUpInside)
            
        case .mine:
            cell.setupPullDownButton(userID: getUserID())
            cell.setupButton(likes: myPosts[indexPath.row].likes, userId: getUserID())
            cell.likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(goToCommentPage), for: .touchUpInside)
            cell.setupStackView(mediaURL: myPosts[indexPath.row].mediaURL)
            
            let docRef = VMEndpoint.user.ref.document(myPosts[indexPath.row].authorId)
            
            firestoreService.getDocument(docRef) { [weak self] (user: User?) in
                guard let self = self else { return }
                self.user = user
                cell.setupPost(
                    name: user!.name,
                    image: user!.userPhotoURL,
                    content: self.myPosts[indexPath.row].content,
                    comments: self.myPosts[indexPath.row].comments,
                    timeStamp: self.myPosts[indexPath.row].time,
                    postId: self.myPosts[indexPath.row].postId,
                    location: self.myPosts[indexPath.row].location
                )
            }
            cell.locationButton.addTarget(self, action: #selector(goToDetailVC), for: .touchUpInside)
        }
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            floatingButton.setMode(.normal, animated: true)
            floatingButton.setTitle("", for: .normal)
        } else if self.lastContentOffset > scrollView.contentOffset.y {
            floatingButton.setTitle("New Post", for: .normal)
            floatingButton.mode = .expanded
        }
    }
}

// MARK: - PostTableViewCellDelegate
extension PostViewController: PostTableViewCellDelegate {
    
    func deletePost(_ cell: PostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError("ERROR") }
        
        let controller = UIAlertController(title: "確定刪除貼文嗎？", message: "你將不會再看到已刪除的貼文", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            
            switch self.currentPage {
            case .all:
                let docRef = VMEndpoint.user.ref.document(getUserID())
                self.firestoreService.arrayRemove(docRef, field: "postIds", value: self.posts[indexPath.row].postId)
                
                let postDocRef = VMEndpoint.post.ref.document(self.posts[indexPath.row].postId)
                self.firestoreService.delete(postDocRef)
                
                guard let postIndex = self.myPosts.firstIndex(where: { $0.postId == self.posts[indexPath.row].postId }) else { return }
                self.myPosts.remove(at: postIndex)
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                CustomFunc.customAlert(title: "已刪除貼文", message: "", vc: self, actionHandler: nil)
            case .mine:
                let docRef = VMEndpoint.user.ref.document(getUserID())
                self.firestoreService.arrayRemove(docRef, field: "postIds", value: self.myPosts[indexPath.row].postId)
                
                let postDocRef = VMEndpoint.post.ref.document(self.myPosts[indexPath.row].postId)
                self.firestoreService.delete(postDocRef)
                
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
            switch self.currentPage {
            case .all:
                let report = Report(
                    userId: getUserID(),
                    postId: self.posts[indexPath.row].postId,
                    time: Timestamp(date: Date())
                )
                let docRef = VMEndpoint.report.ref.document()
                self.firestoreService.setData(report, at: docRef)
                CustomFunc.customAlert(title: "已檢舉完成", message: "謝謝你的意見", vc: self, actionHandler: nil)
            case .mine:
                return
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
                switch self.currentPage {
                case .all:
                    let docRef = VMEndpoint.user.ref.document(getUserID())
                    let authorId = self.posts[indexPath.row].authorId
                    self.firestoreService.arrayUnion(docRef, field: "blockId", value: authorId)
 
                    self.getUserData()
                    self.getPostData()
                    CustomFunc.customAlert(title: "已封鎖該使用者", message: "你將不會再看到該使用者的貼文", vc: self, actionHandler: nil)
                case .mine:
                    return
                }
            }
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            present(controller, animated: true)
        }
    }
