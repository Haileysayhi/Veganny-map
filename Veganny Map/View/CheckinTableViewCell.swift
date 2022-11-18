//
//  CheckinTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/18.
//

import UIKit

class CheckinTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
