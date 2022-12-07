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
    
    // MARK: - prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImgView.image = nil
    }
}
