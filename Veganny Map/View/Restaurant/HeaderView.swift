//
//  HeaderView.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openOrCloseLabel: UILabel!
    
    @IBOutlet weak var view: UIView! {
        didSet {
            view.layer.cornerRadius = 10
        }
    }
}
