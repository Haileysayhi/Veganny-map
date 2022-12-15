//
//  ProfileViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/11.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import KeychainSwift
import AuthenticationServices
import CryptoKit


class ProfileViewController: UIViewController {
    
    
    // MARK: - Properties
    let firestoreService = FirestoreService.shared
    var currentNonce: String?
    var user: User?
    var container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let keychain = KeychainSwift()
    var comments = [Comment]()
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImgView: UIImageView! {
        didSet {
            profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editProfile: UIButton!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        createCircle(startAngle: 0, endAngle: 180)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.width / 1.2 - 15),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImgView.bottomAnchor, constant: 30),
            nameLabel.bottomAnchor.constraint(equalTo: editProfile.topAnchor, constant: -50)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let docRef = VMEndpoint.user.ref.document(userId)
        firestoreService.getDocument(docRef) { [weak self] (user: User?) in
            guard let self = self else { return }
            self.user = user
            self.profileImgView.loadImage(self.user?.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
            self.nameLabel.text = self.user?.name
        }
    }
    
    // MARK: - Function
    private func createSegment(startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.view.frame.midX, y: self.view.frame.minY),
            radius: view.frame.width / 1.2, startAngle: startAngle.toRadians(),
            endAngle: endAngle.toRadians(),
            clockwise: true)
    }
    
    private func createCircle(startAngle: CGFloat, endAngle: CGFloat) {
        let segmentPath = createSegment(startAngle: startAngle, endAngle: endAngle)
        let segmentLayer = CAShapeLayer()
        segmentLayer.path = segmentPath.cgPath
        segmentLayer.lineWidth = 45
        segmentLayer.strokeColor = UIColor.systemOrange.cgColor
        segmentLayer.fillColor = UIColor.systemOrange.cgColor
        container.layer.addSublayer(segmentLayer)
        self.view.insertSubview(container, belowSubview: profileImgView)
    }
    
    @IBAction func signOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                var viewController = self.tabBarController?.viewControllers
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                else { fatalError("ERROR") }
                vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
                viewController?.replaceSubrange(3...3, with: [vc])
                self.tabBarController?.viewControllers = viewController
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func showEditProfilePage(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let controller = UIAlertController(title: "確定刪除帳號嗎？", message: "此步驟無法回復。如果繼續，你的個人檔案、發文、訊息記錄都將被刪除，他人將無法在 Veganny Map 看到你。基於安全性，你將需要重新登入。", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "確定刪除", style: .destructive) { action in
            self.signInWithApple()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        controller.addAction(action)
        if let popoverController = controller.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(
                        x: self.view.bounds.midX,
                        y: self.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popoverController.permittedArrowDirections = []
                }
        present(controller, animated: true, completion: nil)
    }
    
    func revokeToken() {
        guard let refreshToken = keychain.get("refreshToken") else {
            return
        }
        let url = URL(string: "https://appleid.apple.com/auth/revoke?client_id=\(Bundle.main.bundleIdentifier!)&client_secret=\(JWTid().getJWTClientSecret())&token=\(refreshToken)&token_type_hint=refresh_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            print("刪除帳號成功！")
            CustomFunc.customAlert(title: "已刪除帳號", message: "使用者資料已刪除", vc: self, actionHandler: nil)
            
            if let error = error {
                print(error)
            } else {
                print("deleted accont")
            }
        }
        task.resume()
    }
    
    
    func deleteFirebaseData() {
        
        let postQuery = VMEndpoint.post.ref
        // 刪除留言
        firestoreService.getDocuments(postQuery) { [weak self] (posts: [Post]) in
            guard let self = self else { return }
            for post in posts {
                for comment in post.comments {
                    if comment.userId == getUserID() {
                        let deleteComment: [String: Any] = [
                            "content": comment.content,
                            "contentType": comment.contentType,
                            "userId": comment.userId,
                            "time": comment.time
                        ]
                        self.firestoreService.arrayRemove(postQuery.document(post.postId), field: "comments", value: deleteComment) // 刪掉留言
                    }
                }
            }
        }
        // 刪除貼文
        guard let user = user else { return }
        for postId in user.postIds {
            let docRef = VMEndpoint.post.ref.document(postId)
            firestoreService.delete(docRef)
        }
        // 刪黑名單
        let userQuery = VMEndpoint.user.ref
        firestoreService.getDocuments(userQuery) { [weak self] (users: [User]) in
            guard let self = self else { return }
            for user in users {
                self.firestoreService.arrayRemove(userQuery.document(user.userId), field: "blockId", value: getUserID())
            }
        }
        // 刪使用者
        let docRef = VMEndpoint.user.ref.document(getUserID())
        firestoreService.delete(docRef)
        let currentUser = Auth.auth().currentUser
        currentUser?.delete { error in
            if let error = error {
                print("An error happened.")
            } else {
                print("Firebase deleted!")
            }
        }
    }
    
    // MARK: - signInWithApple
    func signInWithApple() {
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

extension ProfileViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        self.deleteFirebaseData()
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
            let user = Auth.auth().currentUser
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticate(with: credential) { result, error  in
                if let error = error {
                    print("An error happened.")
                } else {
                    print("User re-authenticated.")
                    self.revokeToken()
                    CustomFunc.customAlert(title: "刪除完成", message: "期待下次重逢", vc: self, actionHandler: nil)
                    var viewController = self.tabBarController?.viewControllers
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                    else { fatalError("ERROR") }
                    vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
                    viewController?.replaceSubrange(3...3, with: [vc])
                    self.tabBarController?.viewControllers = viewController
                }
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
}
// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面，告知 ASAuthorizationController 該呈現在哪個 Window 上
extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - Extension
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}
