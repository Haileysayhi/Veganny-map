//
//  File.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/23.
//

import Foundation
import UIKit


class SemiCirleView: UIView {
    
    var semiCirleLayer: CAShapeLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let arcCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height)
        let circleRadius = bounds.size.width / 2
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2, clockwise: true)
        
        semiCirleLayer.path = circlePath.cgPath
        semiCirleLayer.fillColor = UIColor.red.cgColor
        
        semiCirleLayer.name = "RedCircleLayer"
        
        if !(layer.sublayers?.contains(where: {$0.name == "RedCircleLayer"}) ?? false) {
            layer.addSublayer(semiCirleLayer)
        }
        
        // Make the view color transparent
        backgroundColor = UIColor.clear
    }
}
