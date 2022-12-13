//
//  PostTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol PostTableViewCellDelegate: AnyObject {
    func deletePost(_ cell: PostTableViewCell)
    func reportPost(_ cell: PostTableViewCell)
    func blockPeople(_ cell: PostTableViewCell)
}

class PostTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var userImgView: UIImageView! {
        didSet {
            userImgView.layer.cornerRadius = userImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numberOfCommentButton: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pullDownButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: PostTableViewCellDelegate?
    let dataBase = Firestore.firestore()
    
    // MARK: - awakeFromNib & prepareForReuse
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImgView.image = nil
    }
    
    // MARK: - Function
    @IBAction func changePage(_ sender: UIPageControl) {
        
        let point = CGPoint(x: scrollView.bounds.width * CGFloat(sender.currentPage), y: 0)
        scrollView.setContentOffset(point, animated: true)
    }
    
    func setupPullDownButton(userID: String) {
        
        pullDownButton.showsMenuAsPrimaryAction = true
        
        if userID == Auth.auth().currentUser?.uid {
            pullDownButton.menu = UIMenu(children: [
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), handler: { action in
                    print("Delete")
                    self.delegate?.deletePost(self)
                })
            ])
        } else {
            pullDownButton.menu = UIMenu(children: [
                UIAction(title: "Block", image: UIImage(systemName: "hand.raised.slash"), handler: { action in
                    print("Block")
                    self.delegate?.blockPeople(self)
                }),
                
                UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.bubble"), handler: { action in
                    print("Report")
                    self.delegate?.reportPost(self)
                })
            ])
        }
    }
    
    func setupButton(likes: [String], userId: String) {
        
        if likes.contains(userId) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemOrange
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .black
        }
    }
    
    func setupStackView(mediaURL: [String]) {
        
        stackView.subviews.forEach { subView in
            subView.removeFromSuperview()
            pageControl.numberOfPages = 0
        }
        
        mediaURL.forEach { imageURL in
            let imageView = UIImageView()
            imageView.loadImage(imageURL, placeHolder: UIImage(named: "placeholder"))
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            stackView.addArrangedSubview(imageView)
            pageControl.numberOfPages += 1
        }
        
        if mediaURL.count == 1 {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
        }
    }
    
    func setupPost(name: String, image: String, content: String, comments: [Comment], timeStamp: Timestamp, postId: String, location: String ) {
        let timeInterval = TimeInterval(Double(timeStamp.seconds))
        
        userNameLabel.text = name
        userImgView.loadImage(image, placeHolder: UIImage(systemName: "person.circle"))
        contentLabel.text = content
        timeLabel.text = timeInterval.getReadableDate()
        
        if comments.isEmpty {
            numberOfCommentButton.isHidden = true
        } else {
            numberOfCommentButton.isHidden = false
            numberOfCommentButton.text = "\(comments.count)"
        }
        
        dataBase.collection("Post").document(postId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let post = try? snapshot.data(as: Post.self) else { return }
            
            if post.likes.isEmpty {
                self.numberOfLikeLabel.isHidden = true
            } else {
                self.numberOfLikeLabel.isHidden = false
                self.numberOfLikeLabel.text = "\(post.likes.count)"
            }
        }
        
        if location.isEmpty {
            locationButton.isHidden = true
        } else {
            locationButton.isHidden = false
            locationButton.setTitle("\(location)", for: .normal)
        }
    }
}
    
    // MARK: - UIScrollViewDelegate
    extension PostTableViewCell: UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let page = scrollView.contentOffset.x / scrollView.bounds.width
            pageControl.currentPage = Int(page)
        }
    }
