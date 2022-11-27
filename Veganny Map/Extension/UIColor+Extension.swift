//
//  UIColor+Extension.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/27.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = hexString.startIndex
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let rrr = Int(color >> 16) & mask
        let ggg = Int(color >> 8) & mask
        let bbb = Int(color) & mask
        let red   = CGFloat(rrr) / 255.0
        let green = CGFloat(ggg) / 255.0
        let blue  = CGFloat(bbb) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var rrr:CGFloat = 0
        var ggg:CGFloat = 0
        var bbb:CGFloat = 0
        var aaa:CGFloat = 0
        getRed(&rrr, green: &ggg, blue: &bbb, alpha: &aaa)
        let rgb:Int = (Int)(rrr*255)<<16 | (Int)(ggg*255)<<8 | (Int)(bbb*255)<<0
        return String(format:"#%06x", rgb)
    }
}
