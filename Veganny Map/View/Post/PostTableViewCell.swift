//
//  PostTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit

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
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
