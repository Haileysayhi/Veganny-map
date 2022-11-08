//
//  PostTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView! {
        didSet {
            userImgView.layer.cornerRadius = userImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var numberOfCommentButton: UIButton!
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
