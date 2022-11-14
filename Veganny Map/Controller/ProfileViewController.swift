//
//  ProfileViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/11.
//

import UIKit

class ProfileViewController: UIViewController {

    
    // MARK: - viewDidLoad

    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemOrange
    }
}
