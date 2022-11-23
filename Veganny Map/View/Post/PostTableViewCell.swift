//
//  PostTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol PostTableViewCellDelegate: AnyObject {
    func deletePost(_ cell: PostTableViewCell)
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
    @IBOutlet weak var numberOfCommentButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl! 
    @IBOutlet weak var pullDownButton: UIButton!
    
    // MARK: - Properties
    let dataBase = Firestore.firestore()
    weak var delegate: PostTableViewCellDelegate?

    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
                }),
                
                UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.bubble"), handler: { action in
                    print("Report")
                })
            ])
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
