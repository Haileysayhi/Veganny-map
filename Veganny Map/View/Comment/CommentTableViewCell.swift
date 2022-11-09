//
//  CommentTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
