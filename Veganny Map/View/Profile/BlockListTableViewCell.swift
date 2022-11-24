//
//  BlockListTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/24.
//

import UIKit

class BlockListTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton! {
        didSet {
            unblockButton.layer.cornerRadius = 5
        }
    }
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
