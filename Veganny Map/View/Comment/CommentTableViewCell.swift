//
//  CommentTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photoImgView: UIImageView! {
        didSet {
            photoImgView.layer.cornerRadius = photoImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
