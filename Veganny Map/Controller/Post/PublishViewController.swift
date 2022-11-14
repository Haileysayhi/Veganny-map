//
//  PublishViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


class PublishViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView! {
        didSet {
            contentTextView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.tintColor = .white
            postButton.layer.cornerRadius = 10
            postButton.backgroundColor = .orange
            postButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Properties
    var imagePickerController = UIImagePickerController()
    let storage = Storage.storage().reference()
    let dataBase = Firestore.firestore()
    var urlString: String?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        showAlert()
    }
    
    // MARK: - Function
    @IBAction func post(_ sender: Any) {
        
        // 跳轉回PostViewController
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is PostViewController {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
        // 傳資料到firebase
        addData()
    }
    
    func showAlert() {
        let controller = UIAlertController(title: "請選取照片來源", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)
        
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { _ in
            guard let viewControllers = self.navigationController?.viewControllers else { return }
            for controller in viewControllers {
                if controller is PostViewController {
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        }
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func takePicture() {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        present(imagePickerController, animated: true)
    }
    
    func addData() {
        let document = dataBase.collection("Post").document()
        print("===>>document ID \(document.documentID)")
        
        
        let post = Post(
            authorId: "fds9KGgchZFsAIvbauMF", // B9SWfBqS3WBBK7TAEZja or fds9KGgchZFsAIvbauMF
            postId: document.documentID,
            content: contentTextView.text,
            mediaType: MediaType.photo.rawValue,
            mediaURL: self.urlString ?? "",
            time: Timestamp(date: Date()),
            likes: [],
            comments: []
        )
        do {
            try document.setData(from: post)
        } catch {
            print("ERROR")
        }
        
        let addPostId = dataBase.collection("User").document("fds9KGgchZFsAIvbauMF") // B9SWfBqS3WBBK7TAEZja or fds9KGgchZFsAIvbauMF
        addPostId.updateData([
            "postIds": FieldValue.arrayUnion([document.documentID])
        ])
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let photoReference = storage.child(UUID().uuidString + ".jpg")
        photoReference.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            photoReference.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                self.urlString = url.absoluteString
                DispatchQueue.main.async {
                    self.photoImgView.image = image
                }
                print("Download URL: \(self.urlString)")
            })
        })
    }
}
