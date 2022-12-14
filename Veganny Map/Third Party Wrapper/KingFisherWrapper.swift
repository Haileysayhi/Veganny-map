//
//  KingFisherWrapper.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {

        guard urlString != nil else { return }
        
        let url = URL(string: urlString!)

        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
