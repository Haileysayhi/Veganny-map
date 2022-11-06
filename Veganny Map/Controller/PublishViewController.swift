//
//  PublishViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/5.
//

import UIKit

class PublishViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: - Properties
    var imagePickerController = UIImagePickerController()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil )
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        showAlert()
    }
    
    @IBAction func post(_ sender: Any) {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is PostViewController {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    // MARK: - Function
    func showAlert() {
        let controller = UIAlertController(title: "請選取照片來源", message: "", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // 開啟相機
    func takePicture() {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    // 開啟相簿
    func openPhotosAlbum() {
        imagePickerController.sourceType = .savedPhotosAlbum
        present(imagePickerController, animated: true)
    }
}
// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.photoImgView.image = image
        }
        picker.dismiss(animated: true)
    }
}
