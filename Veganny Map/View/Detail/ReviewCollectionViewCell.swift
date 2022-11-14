//
//  ReviewCollectionViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/4.
//

import UIKit

class ReviewCollectionViewCell: UICollectionViewCell {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView! {
        didSet {
            backGroundView.layer.cornerRadius = 20
            backGroundView.layer.shadowOpacity = 0.5
            backGroundView.layer.shadowColor = UIColor.systemGray4.cgColor
            backGroundView.layer.shadowOffset = CGSize.zero
            backGroundView.clipsToBounds = false
        }
    }
    
    @IBOutlet var starsButton: [UIButton]!
    
    // MARK: - Function
    func updateStar(rate: Double) {
        for star in starsButton { // Tag come from 1 to 5
            if star.tag <= Int(rate) {
                star.setImage(UIImage(systemName: "star.fill"), for: .normal)
                star.tintColor = .systemOrange
            } else {
                star.setImage(UIImage(systemName: "star"), for: .normal)
                star.tintColor = .black
            }
        }
    }
}
