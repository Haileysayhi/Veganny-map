//
//  DeatilTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/1.
//

import UIKit

class DeatilTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func layoutCell(result: ItemResult) {
        nameLabel.text = result.name
        addressLable.text = result.vicinity
    }
}
