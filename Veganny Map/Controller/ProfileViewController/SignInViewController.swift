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

class SignInViewController: UIViewController {
    
    // MARK: - Properties
    var currentNonce: String?
    var appleUserID: String?
    var animationView: AnimationView!
    var dataBase = Firestore.firestore()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleButton()
        self.observeAppleIDState()
        self.checkAppleIDCredentialState(userID: appleUserID ?? "")
        setupAnimationView()
    }
    
    // MARK: - Function
    
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
                CustomFunc.customAlert(title: "", message: "使用者尚未使用過 Apple ID 登入！", vc: self, actionHandler: nil)
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
                CustomFunc.customAlert(title: "", message: "Unable to fetch identity token", vc: self, actionHandler: nil)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                CustomFunc.customAlert(title: "", message: "Unable to serialize token string from data\n\(appleIDToken.debugDescription)", vc: self, actionHandler: nil)
                return
            }
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            print("appleIDToken: \(String(describing: appleIDCredential.identityToken))")
            print("idTokenString: \(idTokenString)")
            
            var viewController = self.tabBarController?.viewControllers
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let tabController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self))
                    as? TabBarViewController,
                let tabBarControllers = tabController.viewControllers
            else { fatalError("Could not instantiate tabController") }
            viewController?.replaceSubrange(3...3, with: [tabBarControllers[3]])
            self.tabBarController?.viewControllers = viewController

            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential, fullName: appleIDCredential.fullName?.givenName ?? "User")
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
                        savedRestaurants: []
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
        CustomFunc.customAlert(title: "使用者資訊", message: "UID：\(uid)\nEmail：\(email!)", vc: self, actionHandler: nil)
    }
}
