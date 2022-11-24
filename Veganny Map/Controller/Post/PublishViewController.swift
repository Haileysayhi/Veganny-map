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
import SPAlert
import PhotosUI


class PublishViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPhotoImgView)))
        }
    }
    @IBOutlet var photoImgViews: [UIImageView]!
    
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
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationBaground: UIView! {
        didSet {
            locationBaground.layer.cornerRadius = 10
            locationBaground.backgroundColor = .systemGray6
        }
    }
    
    // MARK: - Properties
    var configuration = PHPickerConfiguration()
    let storage = Storage.storage().reference()
    let dataBase = Firestore.firestore()
    var urlString = [String]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        locationBaground.isHidden = true
        selectPhotos()
    }
    
    // MARK: - Function
    @IBAction func tapPhotoImgView(_ sender: UITapGestureRecognizer) {
        selectPhotos()
    }
    
    @IBAction func post(_ sender: Any) {
        if self.urlString == nil {
            CustomFunc.customAlert(title: "照片不可為空", message: "", vc: self, actionHandler: nil)
        } else {
            let alertView = SPAlertView(title: "Done", preset: .done)
            alertView.duration = 1.0
            alertView.present()
            
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
    }
    
    func selectPhotos() {
        configuration.filter = .images
        configuration.selectionLimit = 5
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func addData() {
        let document = dataBase.collection("Post").document()
        print("===>>document ID \(document.documentID)")
        
        let post = Post(
            authorId: getUserID(),
            postId: document.documentID,
            content: contentTextView.text,
            mediaType: MediaType.photo.rawValue,
            mediaURL: self.urlString,
            time: Timestamp(date: Date()),
            likes: [],
            comments: [],
            location: locationLabel.text ?? ""
        )
        do {
            try document.setData(from: post)
        } catch {
            print("ERROR")
        }
        
        let addPostId = dataBase.collection("User").document(getUserID())
        addPostId.updateData([
            "postIds": FieldValue.arrayUnion([document.documentID])
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let locationData = segue.destination as! CheckinViewController
        
        if segue.identifier == "segue" {
            locationData.name = { [weak self] input in
                guard let self = self else { return }
                if input != nil {
                    self.locationBaground.isHidden = false
                    self.locationLabel.text = input
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PublishViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        stackView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
        
        let itemProviders = results.map(\.itemProvider)
        for (i, itemProvider) in itemProviders.enumerated() where itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self, let image = image as? UIImage else { return }
                guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
                let photoReference = self.storage.child(UUID().uuidString + ".jpg")
                photoReference.putData(imageData, metadata: nil, completion: { _, error in
                    guard error == nil else {
                        print("Failed to upload")
                        return
                    }
                    
                    photoReference.downloadURL(completion: { url, error in
                        guard let url = url, error == nil else {
                            return
                        }
                        
                        self.urlString.append(url.absoluteString)
                        DispatchQueue.main.async {
                            let imageView = UIImageView(image: image)
                            imageView.contentMode = .scaleAspectFill
                            imageView.translatesAutoresizingMaskIntoConstraints = false
                            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
                            self.stackView.addArrangedSubview(imageView)
                        }
                        print("Download URL: \(self.urlString)")
                    })
                })
            }
        }
    }
}
