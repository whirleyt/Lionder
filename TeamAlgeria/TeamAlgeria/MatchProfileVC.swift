//
//  MatchProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 12/3/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class MatchProfileVC: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var sexualPreferences: UILabel!
    @IBOutlet weak var agePreferences: UILabel!
    
    @IBOutlet weak var interests: UILabel!
    @IBOutlet weak var clubs: UILabel!
    @IBOutlet weak var extracurriculars: UILabel!

    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var classes: UILabel!
    
    var databaseRef: DatabaseReference!
    var userProfile: UserProfile? = UserProfile()
    var storageRef: StorageReference!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFirebase()

        databaseRef = Database.database().reference()
        
        
            if let email = userProfile?.email {
                let fixedEmail = email.replacingOccurrences(of: ".", with: "_dot_")
                userProfile?.email = email
                let userRef = databaseRef.child("user").child(fixedEmail)

                userRef.observeSingleEvent(of: .value, with: { snapshot in
                    guard let snapshotValue = snapshot.value as? [String: Any] else {
                        print("User data not found.")
                        return
                    }

                    if let userProfile = UserProfile(data: snapshotValue) {
                        self.updateUI(with: userProfile)
                    } else {
                        print("Failed to create UserProfile.")
                    }
                })
            } else {
                print("Email is nil.")
            }
    
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
    }

    func setupFirebase() {
        storageRef = Storage.storage().reference()
        db = Firestore.firestore()
    }

    func fetchFirstPhoto() {
        guard let email = userProfile?.email else {
            return
        }

        let userRef = db.collection("user").document(email).collection("images").document("image0")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.profileImage)
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Document does not exist in Firestore.")
            }
        }
    }

    func loadImageFromStorage(imageURL: String, imageView: UIImageView) {
        if let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
    }

    func updateUI(with userProfile: UserProfile) {
        name.text = userProfile.name
        sexualPreferences.text = "Sexual Preferences: " + userProfile.sexualPreferences
        agePreferences.text = "Age Preferences: " + userProfile.agePreferences
        interests.text = "Interests: " + userProfile.interests
        clubs.text = "Clubs: " + userProfile.clubs
        extracurriculars.text = "Extracurriculars: " + userProfile.extracurriculars
        major.text = "Major: " + userProfile.major
        minor.text = "Minor: " + userProfile.minor
        classes.text = "Classes: " + userProfile.classes

        fetchFirstPhoto()
    }
}
