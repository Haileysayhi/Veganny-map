//
//  CommentTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit
import FirebaseFirestore

class CommentTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
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
    
    // MARK: - Function
    func layoutCell(imgView: String, name: String, content: String, timeStamp: Timestamp) {
        let timeInterval = TimeInterval(Double(timeStamp.seconds))
        photoImgView.loadImage(imgView, placeHolder: UIImage(systemName: "person.circle"))
        nameLabel.text = name
        contentLabel.text = content
        timeLabel.text = timeInterval.getReadableDate()
    }
}
