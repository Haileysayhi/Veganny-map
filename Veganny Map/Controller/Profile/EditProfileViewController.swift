//
//  EditProfileViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/16.
//

import UIKit
import FirebaseAuth
import PhotosUI
import FirebaseStorage
import SPAlert


class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    let firestoreService = FirestoreService.shared
    var user: User?
    var imagePickerController = UIImagePickerController()
    let storage = Storage.storage().reference()
    var urlString: String?
    
    // MARK: - IBOutlet
    @IBOutlet weak var userImgView: UIImageView! {
        didSet {
            userImgView.layer.cornerRadius = userImgView.bounds.width / 2
        }
    }
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
        }
    }
    @IBOutlet weak var uploadButton: UIButton! {
        didSet {
            uploadButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 15
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        getUserData()
    }
    
    // MARK: - Function
    @IBAction func uploadPhoto(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        if let text = nameTextField.text,
           text.isEmpty {
            CustomFunc.customAlert(title: "名字不可為空", message: "請輸入名字", vc: self, actionHandler: nil)
        } else {
            let docRef = VMEndpoint.user.ref.document(getUserID())
            firestoreService.setDataMerge(["name": nameTextField.text,
                                           "userPhotoURL": self.urlString], at: docRef)
            let alertView = SPAlertView(title: "Done", preset: .done)
            alertView.duration = 0.5
            alertView.present()
        }
    }
    
    func getUserData() {
        let docRef = VMEndpoint.user.ref.document(getUserID())
        firestoreService.getDocument(docRef) { [weak self] (user: User?) in
            guard let self = self else { return }
            self.urlString = user?.userPhotoURL
            self.user = user
            self.userImgView.loadImage(self.user?.userPhotoURL, placeHolder: UIImage(systemName: "person.circle"))
            self.nameTextField.text = self.user?.name
            self.nameTextField.font = UIFont.systemFont(ofSize: 18)
        }
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
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                    self.userImgView.image = image
                }
                print("Download URL: \(self.urlString)")
            })
        })
    }
}
