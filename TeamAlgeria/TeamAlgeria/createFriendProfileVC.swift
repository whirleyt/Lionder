//  createFriendProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class createFriendProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var interests: UITextField!
    @IBOutlet weak var clubs: UITextField!
    @IBOutlet weak var extracurriculars: UITextField!
    @IBOutlet var imageView: UIImageView!


        var userProfile: UserProfile?
        var storageRef: StorageReference!
        var db: Firestore!

        override func viewDidLoad() {
            super.viewDidLoad()
            interests?.delegate = self
            clubs?.delegate = self
            extracurriculars?.delegate = self
            setupFirebase()
            fetchFirstPhoto()
        }

        func setupFirebase() {
            storageRef = Storage.storage().reference()
            db = Firestore.firestore()
        }

        func fetchFirstPhoto() {
            guard let email = userProfile?.email else {
                return
            }
            
            let userRef = db.collection("user").document(email).collection("images").document("image1")

            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let imageName = document.data()?["downloadURL"] as? String {
                        self.loadImageFromStorage(imageURL: imageName)
                    } else {
                        print("No download URL found in Firestore.")
                    }
                } else {
                    print("Document does not exist in Firestore.")
                }
            }
        }

        func loadImageFromStorage(imageURL: String) {
            if let url = URL(string: imageURL) {
                imageView.sd_setImage(with: url, completed: nil)
            }
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
        case "interests":
            userProfile?.interests = textField.text ?? ""
        case "clubs":
            userProfile?.clubs = textField.text ?? ""
        case "extracurriculars":
            userProfile?.extracurriculars = textField.text ?? ""
        default:
            print("Unhandled identifier: \(identifier)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createStudyProfileVC {
            self.userProfile?.extracurriculars = extracurriculars.text ?? ""
            destination.userProfile = self.userProfile
        }
    }
}
