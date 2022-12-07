//
//  InfoTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var workHourLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var callButton: UIButton! {
        didSet {
            callButton.layer.cornerRadius = 10
        }
    }
    
    // MARK: - Properties
    var savedRestaurants: [String] = []
    var placeId: String?
    
    // MARK: - function
    func layoutCell(name: String, address: String, workHour: String, phone: String, reviews: String) {
        nameLabel.text = name
        addressLabel.text = address
        workHourLabel.text = workHour
        phoneLabel.text = phone
        reviewsLabel.text = reviews
    }
    
    func setupButton(savedRestaurants: [String], placeId: String) {
        if savedRestaurants.contains(placeId) {
            saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            saveButton.tintColor = .systemPink
        } else {
            saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
            saveButton.tintColor = .systemOrange
        }
    }
}
