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
    
    // MARK: - 取得送出/更新留言的當下時間
    class func getSystemTime() -> String {
        let currectDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currectDate)
    }
}


//extension ViewController: ASAuthorizationControllerDelegate {
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//            let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                      idToken: idTokenString,
//                                                      rawNonce: nonce)
//            Auth.auth().signIn(with: credential) { (authResult, error) in
//                if (error != nil) {
//                    // Error. If error.code == .MissingOrInvalidNonce, make sure
//                    // you're sending the SHA256-hashed nonce as a hex string with
//                    // your request to Apple.
//                    print(error?.localizedDescription ?? "")
//                    return
//                }
//                guard let user = authResult?.user else { return }
//                let email = user.email ?? ""
//                let displayName = user.displayName ?? ""
//                guard let uid = Auth.auth().currentUser?.uid else { return }
//                let db = Firestore.firestore()
//                db.collection("User").document(uid).setData([
//                    "email": email,
//                    "displayName": displayName,
//                    "uid": uid
//                ]) { err in
//                    if let err = err {
//                        print("Error writing document: \(err)")
//                    } else {
//                        print("the user has sign up or is logged in")
//                    }
//                }
//            }
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        // Handle error.
//        print("Sign in with Apple errored: \(error)")
//    }
//} 
