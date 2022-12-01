//
//  SignInViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/15.
//

import UIKit
import FirebaseAuth // Connect with firebase
import AuthenticationServices // Sign in with apple
import CryptoKit // Create random String (Nonce)
import Firebase
import Lottie
import SwiftUI
import KeychainSwift
import SafariServices

class SignInViewController: UIViewController {
    
    // MARK: - Properties
    var currentNonce: String?
    var appleUserID: String?
    var animationView: AnimationView!
    var dataBase = Firestore.firestore()
    let keychain = KeychainSwift()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleButton()
        self.observeAppleIDState()
        self.checkAppleIDCredentialState(userID: appleUserID ?? "")
        setupAnimationView()
        
        let privacyButton = UIButton()
        privacyButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        privacyButton.tintColor = .systemOrange
        privacyButton.layer.cornerRadius = 15
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(privacyButton)
        
        NSLayoutConstraint.activate([
            privacyButton.widthAnchor.constraint(equalToConstant: 50),
            privacyButton.heightAnchor.constraint(equalToConstant: 50),
            privacyButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            privacyButton.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 10)
        ])
        privacyButton.addTarget(self, action: #selector(privacyPolicy), for: .touchUpInside)
    }
    
    // MARK: - Function
    @objc func privacyPolicy() {
        if let url = URL(string: "https://www.privacypolicies.com/live/551f2624-e971-4107-84da-175188788ebb") {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    func setupAnimationView() {
        animationView = .init(name: "84914-purple")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        view.addSubview(animationView)
        view.sendSubviewToBack(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -160),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        animationView.play()
    }
    
    // 監聽目前的 Apple ID 的登入狀況
    // 主動監聽
    func checkAppleIDCredentialState(userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: getUserID()) { credentialState, error in
            switch credentialState {
            case .authorized: // 用戶已登入
                CustomFunc.customAlert(title: "使用者已授權！", message: "", vc: self, actionHandler: nil)
                // 進入主畫面
            case .revoked: // 用戶已登出
                CustomFunc.customAlert(
                    title: "使用者憑證已被註銷，請重新使用 Apple ID 登入！",
                    message: "請到\n「設定 → Apple ID → 密碼與安全性 → 使用 Apple ID 的 App」\n將此 App 停止使用 Apple ID\n並再次使用 Apple ID 登入本 App！",
                    vc: self,
                    actionHandler: nil)
            case .notFound: // 無此用戶
                print("使用者尚未使用過 Apple ID 登入！")
                //                CustomFunc.customAlert(title: "", message: "使用者尚未使用過 Apple ID 登入！", vc: self, actionHandler: nil)
                // 跳轉到登入畫面
            case .transferred:
                CustomFunc.customAlert(title: "請與開發者團隊進行聯繫，以利進行使用者遷移！", message: "", vc: self, actionHandler: nil)
            default:
                break
            }
        }
    }
    
    // 被動監聽 (使用 Apple ID 登入或登出都會觸發)
    func observeAppleIDState() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (notification: Notification) in
            CustomFunc.customAlert(title: "使用者登入或登出", message: "", vc: self, actionHandler: nil)
        }
    }
    
    // 使用ASAuthorizationAppleIDButton來建立button
    func setSignInWithAppleButton() {
        let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: chooseAppleButtonStyle())
        view.addSubview(signInWithAppleButton)
        signInWithAppleButton.cornerRadius = 15
        signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: 280),
            signInWithAppleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    // 淺色模式就顯示黑色的按鈕，深色模式就顯示白色的按鈕
    func chooseAppleButtonStyle() -> ASAuthorizationAppleIDButton.Style {
        return (UITraitCollection.current.userInterfaceStyle == .light) ? .black : .white
    }
    
    @objc func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider() // 建立取得使用者資訊的請求 82~84
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while(remainingLength > 0) {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if (errorCode != errSecSuccess) {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if (remainingLength == 0) {
                    return
                }
                
                if (random < charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 登入成功
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data\n\(appleIDToken.debugDescription)")
                return
            }
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            print("appleIDToken: \(String(describing: appleIDCredential.identityToken))")
            print("idTokenString: \(idTokenString)")
            
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential, fullName: appleIDCredential.fullName?.givenName ?? "User")
            
            // authorizationCode
            if let authorizationCode = appleIDCredential.authorizationCode,
               let codeString = String(data: authorizationCode, encoding: .utf8) {
                print("===JWT--authorizationCode===\(codeString)")
                getRefreshToken(codeString: codeString)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            CustomFunc.customAlert(title: "使用者取消登入", message: "", vc: self, actionHandler: nil)
            break
        case ASAuthorizationError.failed:
            CustomFunc.customAlert(title: "授權請求失敗", message: "", vc: self, actionHandler: nil)
            break
        case ASAuthorizationError.invalidResponse:
            CustomFunc.customAlert(title: "授權請求無回應", message: "", vc: self, actionHandler: nil)
            break
        case ASAuthorizationError.notHandled:
            CustomFunc.customAlert(title: "授權請求未處理", message: "", vc: self, actionHandler: nil)
            break
        case ASAuthorizationError.unknown:
            CustomFunc.customAlert(title: "授權失敗，原因不知", message: "", vc: self, actionHandler: nil)
            break
        default:
            break
        }
    }
    
    
    func getRefreshToken(codeString: String) {
        let url = URL(string: "https://appleid.apple.com/auth/token?client_id=\(Bundle.main.bundleIdentifier!)&client_secret=\(JWTid().getJWTClientSecret())&code=\(codeString)&grant_type=authorization_code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                    print("===tokenResponse:\(tokenResponse)")
                    self.keychain.set(tokenResponse.refreshToken, forKey: "refreshToken")
                } catch {
                    print("\(error)")
                }
            }
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            if let error = error {
                print(error)
            } else {
                print("deleted accont")
            }
        }
        task.resume()
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面，告知 ASAuthorizationController 該呈現在哪個 Window 上
extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// 透過 Credential 與 Firebase Auth 串接
extension SignInViewController {
    func firebaseSignInWithApple(credential: AuthCredential, fullName: String) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            CustomFunc.customAlert(title: "登入成功！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
            
            // 跳轉頁面
            var viewController = self.tabBarController?.viewControllers
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let tabController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self))
                    as? TabBarViewController,
                let tabBarControllers = tabController.viewControllers
            else { fatalError("Could not instantiate tabController") }
            
            viewController?.replaceSubrange(3...3, with: [tabBarControllers[3]])
            self.tabBarController?.viewControllers = viewController
            self.tabBarController?.selectedIndex = 3
            self.dismiss(animated: true)
            
            guard let user = authResult?.user else { return }
            let email = user.email ?? ""
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.dataBase.collection("User").document(getUserID()).getDocument { documentSnapshot, error in
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    return
                } else {
                    let userData = User(
                        name: fullName,
                        userPhotoURL: "",
                        userId: getUserID(),
                        email: email,
                        postIds: [],
                        savedRestaurants: [],
                        blockId: []
                    )
                    do {
                        try self.dataBase.collection("User").document(getUserID()).setData(from: userData)
                    } catch {
                        print("ERROR")
                    }
                }
            }
        }
    }
    
    // Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser // 取得一整包使用者的資料
        guard let user = currentUser else {
            CustomFunc.customAlert(title: "無法取得使用者資料！", message: "", vc: self, actionHandler: nil)
            return
        }
        let uid = user.uid
        let email = user.email
        print("使用者資訊:UID：\(uid)\nEmail：\(email!)")
    }
}
