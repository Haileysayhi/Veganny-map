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
    @IBOutlet weak var photoImgView: UIImageView! {
        didSet {
            photoImgView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - Function
    func layoutCell(photoReference: String, name: String, address: String) {
        GoogleMapListController.shared.fetchPhotos(photoReference: photoReference) { image in
            DispatchQueue.main.async {
            self.nameLabel.text = name
            self.photoImgView.image = (image ?? UIImage(named: "placeholder"))!
            self.addressLabel.text = address
            }
        }
    }
}
