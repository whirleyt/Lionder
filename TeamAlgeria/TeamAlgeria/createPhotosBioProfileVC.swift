//  createPhotosBioProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class createPhotosBioProfileVC: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bio: UITextField!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var selectImageButtons: [UIButton]!

    var userProfile: UserProfile?
    var selectedImages: [String?] = Array(repeating: nil, count: 4) // Store download URLs
    let imagePicker = UIImagePickerController()
    var storageRef: StorageReference!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()

        bio?.delegate = self
        imagePicker.delegate = self
        setupFirebase()
    }

    func setupFirebase() {
        storageRef = Storage.storage().reference()
        db = Firestore.firestore()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        processTextFieldInput(textField)
    }

    func processTextFieldInput(_ textField: UITextField) {
        guard let identifier = textField.accessibilityIdentifier else {
            print("Error: Text field has no accessibility identifier")
            return
        }

        switch identifier {
        case "bio":
            userProfile?.bio = textField.text ?? ""
        default:
            print("Unhandled identifier: \(identifier)")
        }
    }

    @IBAction func selectImageTapped(_ sender: UIButton) {
        presentImagePicker(tag: sender.tag)
    }

    func presentImagePicker(tag: Int) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            if imagePicker.presentingViewController == nil {
                imagePicker.sourceType = .photoLibrary
                imagePicker.modalPresentationStyle = .popover
                present(imagePicker, animated: true, completion: nil)
                imagePicker.popoverPresentationController?.sourceView = view
                imagePicker.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                imagePicker.popoverPresentationController?.permittedArrowDirections = []
                imagePicker.popoverPresentationController?.delegate = self
                imagePicker.view.tag = tag
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        if let tag = picker.view?.tag, tag >= 1 && tag <= imageViews.count {
            let imageName = UUID().uuidString.replacingOccurrences(of: "-", with: "") + ".jpg"

            selectedImages[tag - 1] = imageName

            imageViews[tag - 1].image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createDatingProfileVC {
            self.userProfile?.bio = bio.text ?? ""
            destination.userProfile = self.userProfile
            for (index, selectedImage) in selectedImages.enumerated() {
                storePicIntoFirebase(imageIndex: index)
            }
        }
    }

    func storePicIntoFirebase(imageIndex: Int) {
        guard let email = userProfile?.email else {
            return
        }

        guard let imageData = imageViews[imageIndex].image?.jpegData(compressionQuality: 0.7) else {
            return
        }

        let imageName = UUID().uuidString.replacingOccurrences(of: "-", with: "") + ".jpg"

        let storageRef = Storage.storage().reference().child("user/\(email)/images/\(imageName)")
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading image to Cloud Storage: \(error.localizedDescription)")
            } else {
                print("Image uploaded successfully!")

                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        Firestore.firestore().collection("user").document(email).collection("images").document("image\(imageIndex)").setData(["downloadURL": downloadURL.absoluteString])
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
    }
}
