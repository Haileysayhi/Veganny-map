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
    
    // MARK: - Function
    func layoutCell(name: String, address: String) {
        nameLabel.text = name
        addressLabel.text = address
    }
}
