//
//  SaveTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/10.
//

import UIKit

class SaveTableViewCell: UITableViewCell {

    
    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImgView: UIImageView!
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
