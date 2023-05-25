//
//  ReviewDetailViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/22.
//

import UIKit

class ReviewDetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet var starsButton: [UIButton]!
    @IBOutlet weak var backGroundView: UIView! {
        didSet {
            backGroundView.layer.cornerRadius = 10
            backGroundView.clipsToBounds = false
        }
    }
    
    // MARK: - Properties
    var review: Reviews?
    var dateFormatter = DateFormatter()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        getReview()
    }
    
    // MARK: - Function
    func getReview() {
        guard let review = review else { return }
    
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        nameLabel.text = review.authorName
        dateLabel.text = dateFormatter.string(from: review.time)
        contentLabel.text = review.text
        updateStar(rate: review.rating)
        GoogleMapService.shared.getPhoto(url: review.profilePhotoURL) { image in
            DispatchQueue.main.async {
                self.profileImgView.image = image
            }
        }
    }
    
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
