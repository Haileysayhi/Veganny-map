//
//  CustomFunc.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/15.
//

import Foundation
import UIKit

class CustomFunc {
    /// 提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話就填 nil
    class func customAlert(title: String, message: String, vc: UIViewController, actionHandler: (() -> Void)?) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "關閉", style: .default) { action in
                actionHandler?()
            }
            alertController.addAction(closeAction)
            vc.present(alertController, animated: true)
        }
    }
}
