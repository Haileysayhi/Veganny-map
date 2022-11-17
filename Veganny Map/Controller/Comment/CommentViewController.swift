//
//  CommentViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        group.enter()
        dataBase.collection("Post").document(postId).getDocument(as: Post.self) { result in
            switch result {
            case .success(let post):
                print(post)
                self.comments = post.comments
                print("===comments\(self.comments)")
                self.group.leave()
            case .failure(let error):
                print(error)
                self.group.leave()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getUserData(userId: String) {
        group.enter()
        dataBase.collection("User").document(userId).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                print(user)
                self.user = user
                self.group.leave()
            case .failure(let error):
                print(error)
                self.group.leave()
            }
        }
    }
    
    func getReadableDate(timeStamp: TimeInterval) -> String? {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if dateFallsInCurrentWeek(date: date) {
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: date)
            } else {
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: date)
            }
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    func dateFallsInCurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == datesWeek)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else { fatalError("Could not creat Cell.") }
        
        self.getUserData(userId: self.comments[indexPath.row].userId)
        self.group.notify(queue: DispatchQueue.main) {
            cell.nameLabel.text = self.user?.name
            cell.photoImgView.loadImage(self.user?.userPhotoURL, placeHolder: UIImage(named: "placeholder"))
            cell.contentLabel.text = self.comments[indexPath.row].content
            let timeStamp = self.comments[indexPath.row].time
            let timeInterval = TimeInterval(Double(timeStamp.seconds))
            cell.timeLabel.text = timeInterval.getReadableDate()
        }
        return cell
    }
}
